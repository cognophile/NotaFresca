
import Foundation
import SQLite

class DatabaseHelper {
    private var connection: Connection?
    
    init() {
        self.openConnection()
    }
    
    public func createTable(model: BaseModel) {
        try! self.connection?.run(model.createTable()!)
    }
    
    public func selectAll(model: BaseModel) -> AnySequence<Row>? {
        if let records = try! self.connection?.prepare(model.table!) {
            return records
        }
        
        return nil
    }
    
    public func selectOne(model: BaseModel, index: Int) -> Row? {
        guard let statement = model.table?.filter(model.id == index) else { return nil }
        
        if let record = try! self.connection?.pluck(statement) {
            return record
        }
        
        return nil
    }
    
    public func insert(model: BaseModel, query: Insert) -> Row? {
        try! self.connection?.run(query)
        guard let statement = model.table?.order(model.id.desc).limit(1) else { return nil }
        
        if let record = try! self.connection?.pluck(statement) {
            return record
        }
        
        return nil
    }
    
    public func update(model: BaseModel, index: Int, query: [Setter]) -> Row? {
        guard let statement = model.table?.filter(model.id == index) else { return nil }
        
        if let record = try! self.connection?.run(statement.update(query)) {
            if let updated = try! self.connection?.pluck(statement) {
                return updated
            }
        }
        
        return nil
    }
    
    
    public func delete(model: BaseModel, index: Int) -> Int? {
        guard let statement = model.table?.filter(model.id == index) else { return nil }
        
        if let record = try! self.connection?.run(statement.delete()) {
            return record
        }
        
        return nil
    }
    
    private func openConnection() {
        let databasePath = NSSearchPathForDirectoriesInDomains( .applicationSupportDirectory, .userDomainMask, true).first! + "/" + Bundle.main.bundleIdentifier!
        
        try! FileManager.default.createDirectory(
            atPath: databasePath, withIntermediateDirectories: true, attributes: nil
        )
        
        let connection = try! Connection("\(databasePath)/notafresca.sqlite3")
        self.connection = connection
    }
}
