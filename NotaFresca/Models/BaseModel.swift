
import Foundation
import SQLite

class BaseModel {
    var table: Table?
    var id = Expression<Int>("id")
    var optId = Expression<Int?>("id")
    
    var record: Row?
    var data = NoteDataStruct()
    
    func createTable() -> String? {
        return nil
    }
    
    func getId() -> Int? {
        return nil
    }
}
