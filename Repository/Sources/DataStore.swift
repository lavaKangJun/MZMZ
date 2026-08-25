//
//  DataStore.swift
//  Repository
//
//  Created by 강준영 on 2025/05/08.
//

import Foundation
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
    private let tableName = "LocationInfo"
    
    private init() {
        self.dbPointer = openDatabase()
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    private func openDatabase() -> OpaquePointer? {
        var dbPointer: OpaquePointer?
        do {
            guard let filePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.junyoung.mzmz") else { return nil }
            
            let dbURL = filePath.appendingPathComponent(databaseName)
            if sqlite3_open(dbURL.path(), &dbPointer) != SQLITE_OK {
                print("Fail create DB")
                return nil
            } else {
                return dbPointer
            }
        } catch {
            print("Fail create file path", error)
            return nil
        }
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
        createdAt INTEGER NOT NULL,
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
            INSERT OR REPLACE INTO \(tableName) (location, longitude, latitude, isFavorite, createdAt)
            VALUES (?, ?, ?, ?, ?, ?, ?);
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
    
    public func delete(location: String) throws -> Bool {
        let statement = """
        DELETE FROM \(tableName) WHERE location == '\(location)'
        """
        
        let deleteStatement = try prepareStatement(statement)
        let result = sqlite3_step(deleteStatement)
        
        sqlite3_finalize(deleteStatement)
        
        if result == SQLITE_DONE {
            return true
        } else {
            return false
        }
    }
    
    public func load() throws -> [DustStoreDTO] {
        try createTable()
        
        let statement = """
        SELECT * FROM \(tableName) ORDER BY createdAt DESC
        """
        
        let loadStatement = try prepareStatement(statement)
        var dto: [DustStoreDTO] = []
        var result = sqlite3_step(loadStatement)
        while result == SQLITE_ROW {
            let location = String(cString: sqlite3_column_text(loadStatement, 0))
            let longitude = String(cString: sqlite3_column_text(loadStatement, 1))
            let latitude = String(cString: sqlite3_column_text(loadStatement, 2))
            let isFavorite = sqlite3_column_int(loadStatement, 4)
            let timeStamp = sqlite3_column_int(loadStatement, 5)
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
        
        let statement = "UPDATE LocationInfo SET isFavorite = ? WHERE location = ?;"
        let updateStatement = try prepareStatement(statement)
 
        defer { sqlite3_finalize(updateStatement) }
        
        sqlite3_bind_int(updateStatement, 1, isFavorite ? 1 : 0)
        sqlite3_bind_text(updateStatement, 2, (location as NSString).utf8String, -1, nil)
        
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
