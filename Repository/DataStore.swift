//
//  DataStore.swift
//  Repository
//
//  Created by 강준영 on 2025/05/08.
//

import Foundation
import SQLite3

public protocol DataStorable {
    func getDustInfo() -> [DustStoreDTO]
    func setDustInfo(_ info: DustStoreDTO)
    func insertTable(data: DustStoreDTO) throws
    func load() throws -> [DustStoreDTO]
}

public enum SQLiteError: Error {
    case close
    case open
    case prepare
    case step(String)
    case transation(String)
}

public final class DataStore: DataStorable {
    public static let shared = DataStore()
    private var dustInfos: [DustStoreDTO] = []
    private var dbPointer: OpaquePointer?
    private let databaseName = "mzmz.sqlite.db"
    
    private init() {
        self.dbPointer = openDatabase()
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    private func openDatabase() -> OpaquePointer? {
        var dbPointer: OpaquePointer?
        do {
            let filePath = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            ).path()
            
            if sqlite3_open("\(filePath)/\(databaseName)", &dbPointer) != SQLITE_OK {
                print("Fail create DB")
                return nil
            } else {
                return dbPointer
            }
        } catch {
            print("Fail create file path")
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
        CREATE TABLE IF NOT EXISTS LocationDust (
        location TEXT NOT NULL,
        longitude TEXT NOT NULL,
        latitude TEXT NOT NULL,
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
        let timestamp = Int(Date().timeIntervalSince1970)
        
        try createTable()
        
        let statement = """
        INSERT OR REPLACE INTO LocationDust (location, longitude, latitude, createdAt) VALUES ('\(data.location)', '\(data.longitude)', '\(data.latitude)', '\(timestamp)');
        """
        
        guard sqlite3_exec(dbPointer, statement, nil, nil, nil) == SQLITE_OK else {
            throw SQLiteError.transation("insert")
        }
    }
    
    public func load() throws -> [DustStoreDTO] {
        try createTable()
        
        let statement = """
        SELECT * FROM LocationDust ORDER BY createdAt ASC
        """
        
        let loadStatement = try prepareStatement(statement)
        var dto: [DustStoreDTO] = []
        var result = sqlite3_step(loadStatement)
        while result == SQLITE_ROW {
            let location = String(cString: sqlite3_column_text(loadStatement, 0))
            let longitude = String(cString: sqlite3_column_text(loadStatement, 1))
            let latitude =  String(cString: sqlite3_column_text(loadStatement, 2))
            dto.append(DustStoreDTO(location: location, longitude: longitude, latitude: latitude))
            result = sqlite3_step(loadStatement)
        }
        
        sqlite3_finalize(loadStatement)
        
        return dto
    }
    
    public func getDustInfo() -> [DustStoreDTO] {
        return dustInfos
    }
     
    public func setDustInfo(_ info: DustStoreDTO) {
        self.dustInfos.append(info)
    }
}
