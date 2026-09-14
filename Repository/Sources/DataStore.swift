//
//  DataStore.swift
//  Repository
//
//  Created by 강준영 on 2025/05/08.
//

import Foundation
import os
import SQLite3

public protocol DataStorable: Sendable {
    func insertTable(data: DustStoreDTO) throws
    func load() throws -> [DustStoreDTO]
    func delete(location: String) throws -> Bool
    func setFavorite(location: String, isFavorite: Bool) throws
    func getFavoriteStatus(location: String) throws -> Bool
}

public enum SQLiteError: Error {
    case close
    case open
    case prepare
    case step(String)
    case transation(String)
    case overLike(String)
}

public final class DataStore: DataStorable, @unchecked Sendable {
    @MainActor public static let shared = DataStore()
    private var dustInfos: [DustStoreDTO] = []
    private var dbPointer: OpaquePointer?
    private let databaseName = "mzmz.sqlite.db"
    private let appGroupIdentifier = "group.com.junyoung.mzmz"

    /// DB 열기 실패를 남긴다.
    ///
    /// Crashlytics 를 쓰면 안 된다. 이 타입은 싱글턴이라 처음 접근할 때
    /// 만들어지는데, 그 시점이 FirebaseApp.configure() 보다 앞설 수 있다
    /// (위젯의 MZMZWidzet.init() 이 DataStore.shared 를 건드린다).
    /// 그러면 Crashlytics 호출이 조용히 무시돼 실패가 어디에도 안 남는다.
    /// os.Logger 는 Firebase 와 무관하게 항상 찍힌다.
    /// 확인: Console.app 에서 "MZMZDataStore" 검색
    private static let logger = Logger(subsystem: "MZMZDataStore", category: "SQLite")
    private let tableName = "LocationInfo"
    
    private init() {
        self.dbPointer = openDatabase()
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    /// 앱과 위젯이 공유하는 SQLite 파일을 연다.
    ///
    /// 실패하면 dbPointer 가 nil 로 남고 이후 모든 질의가 prepare 에서 깨진다.
    /// 그 프로세스는 계속 빈 목록을 보게 되므로(위젯이면 "즐겨찾기 없음" 화면)
    /// 실패 사유를 반드시 남긴다. 예전에는 Crashlytics 로 남겼는데, 초기화 전에
    /// 불릴 수 있어 아무 데도 안 남는 경우가 있었다.
    private func openDatabase() -> OpaquePointer? {
        var dbPointer: OpaquePointer?

        guard let filePath = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            // App Group entitlement 문제. 앱/위젯 중 한쪽만 그럴 수도 있다.
            Self.logger.error(
                "#DB App Group 컨테이너 없음 group=\(self.appGroupIdentifier, privacy: .public) bundle=\(Bundle.main.bundleIdentifier ?? "-", privacy: .public)"
            )
            return nil
        }

        let dbURL = filePath.appendingPathComponent(databaseName)
        let code = sqlite3_open(dbURL.path(), &dbPointer)
        guard code == SQLITE_OK else {
            let message = dbPointer.map { String(cString: sqlite3_errmsg($0)) } ?? "-"
            Self.logger.error(
                "#DB DB 열기 실패 code=\(code) msg=\(message, privacy: .public) path=\(dbURL.path(), privacy: .public)"
            )
            return nil
        }
        return dbPointer
    }
    
    private func close() -> Result<Void, Error> {
        if self.dbPointer != nil {
            sqlite3_close(self.dbPointer)
            return .success(())
        } else {
            return .failure(SQLiteError.close)
        }
    }
    
    private func prepareStatement(_ string: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, string, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.prepare
        }
        return statement
    }
    
    public func createTable() throws {
        let statement =
        """
        CREATE TABLE IF NOT EXISTS \(tableName) (
        location TEXT NOT NULL,
        longitude TEXT NOT NULL,
        latitude TEXT NOT NULL,
        isFavorite INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        PRIMARY KEY (location)
        );
        """
        let createStatement = try prepareStatement(statement)
        
        defer {
            sqlite3_finalize(createStatement)
        }
        
        guard sqlite3_step(createStatement) == SQLITE_DONE else {
            throw SQLiteError.step("create")
        }
    }
    
    public func insertTable(data: DustStoreDTO) throws {
        try createTable()
        
        let sql = """
            INSERT OR REPLACE INTO \(tableName) (location, longitude, latitude, isFavorite, updatedAt)
            VALUES (?, ?, ?, ?, ?);
            """
        let statement = try prepareStatement(sql)
        defer { sqlite3_finalize(statement) }
        
        sqlite3_bind_text(statement, 1, (data.location as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (data.longitude as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (data.latitude as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 4, data.isFavorite ? 1 : 0)
        sqlite3_bind_int64(statement, 5, Int64(Date().timeIntervalSince1970))
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step("insert")
        }
    }
    
    /// 지역을 지운다. 실제로 지워진 행이 있으면 true.
    ///
    /// SQLITE_DONE 만 보고 판단하면 안 된다. DELETE 는 조건에 맞는 행이 하나도
    /// 없어도 DONE 을 돌려주기 때문에 "지웠다" 와 "지울 게 없었다" 가 구분되지
    /// 않는다. 예전에는 그래서 항상 true 였고, 호출부(DustListViewModel)는
    /// 성공으로 보고 메모리 목록에서 지워 화면에서는 사라졌다. DB 에는 남아
    /// 있으니 같은 DB 를 읽는 위젯에는 계속 보였다.
    ///
    /// 몇 행이 바뀌었는지는 sqlite3_changes 로 확인한다.
    /// 지역명은 문자열로 이어붙이지 않고 바인딩한다(따옴표 등으로 깨지지 않게).
    public func delete(location: String) throws -> Bool {
        let sql = "DELETE FROM \(tableName) WHERE location = ?"
        let statement = try prepareStatement(sql)
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (location as NSString).utf8String, -1, nil)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step("delete")
        }
        return sqlite3_changes(dbPointer) > 0
    }
    
    public func load() throws -> [DustStoreDTO] {
        try createTable()
        
        // 즐겨찾기(1)가 먼저, 그 안에서는 최근에 즐겨찾기한 순.
        // 즐겨찾기가 아닌 항목은 최근에 추가한 순.
        let statement = """
        SELECT * FROM \(tableName) ORDER BY isFavorite DESC, updatedAt DESC
        """
        
        let loadStatement = try prepareStatement(statement)
        var dto: [DustStoreDTO] = []
        var result = sqlite3_step(loadStatement)
        while result == SQLITE_ROW {
            let location = String(cString: sqlite3_column_text(loadStatement, 0))
            let longitude = String(cString: sqlite3_column_text(loadStatement, 1))
            let latitude = String(cString: sqlite3_column_text(loadStatement, 2))
            // 컬럼 순서: 0 location, 1 longitude, 2 latitude,
            // 3 isFavorite, 4 updatedAt
            let isFavorite = sqlite3_column_int(loadStatement, 3)
            dto.append(DustStoreDTO(location: location, longitude: longitude, latitude: latitude, isFavorite: isFavorite == 0 ? false : true))
            result = sqlite3_step(loadStatement)
        }
        
        sqlite3_finalize(loadStatement)
        
        return dto
    }

    public func setFavorite(location: String, isFavorite: Bool) throws {
        if isFavorite {
            let favoriteCount =  try getFavoriteCount()
            if favoriteCount >= 2 {
                throw SQLiteError.overLike("최대 2가까지 즐겨찾기 가능합니다.")
            }
        }
        
        // updatedAt 을 같이 갱신해야 방금 즐겨찾기한 항목이 맨 위로 온다.
        let statement = """
        UPDATE \(tableName) SET isFavorite = ?, updatedAt = ? WHERE location = ?;
        """
        let updateStatement = try prepareStatement(statement)
 
        defer { sqlite3_finalize(updateStatement) }
        
        sqlite3_bind_int(updateStatement, 1, isFavorite ? 1 : 0)
        sqlite3_bind_int64(updateStatement, 2, Int64(Date().timeIntervalSince1970))
        sqlite3_bind_text(updateStatement, 3, (location as NSString).utf8String, -1, nil)
        
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            throw SQLiteError.step("favorite update error")
        }
    }
    
    private func getFavoriteCount() throws -> Int {
        
        let state = "SELECT COUNT(*) FROM LocationInfo WHERE isFavorite == 1"
        let favoriteStatement = try prepareStatement(state)
        defer {
            sqlite3_finalize(favoriteStatement)
        }
        guard sqlite3_step(favoriteStatement) == SQLITE_ROW else {
            throw SQLiteError.step("favorite count error")
        }
        
        let count = sqlite3_column_int(favoriteStatement, 0)
        return Int(count)
    }
    
    public func getFavoriteStatus(location: String) throws -> Bool {
        let statement = "SELECT isFavorite FROM LocationInfo WHERE location = '\(location)'"
        
        let favoriteStatement = try prepareStatement(statement)
        defer {
            sqlite3_finalize(favoriteStatement)
        }
        
        guard sqlite3_step(favoriteStatement) == SQLITE_ROW else {
            return false // 해당 지역이 없으면 false
        }
        
        let isFavorite = sqlite3_column_int(favoriteStatement, 0)
        return isFavorite == 1
    }
}
