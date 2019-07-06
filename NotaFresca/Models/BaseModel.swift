
import Foundation
import SQLite

class BaseModel {
    var table: Table?
    var id = Expression<Int>("id")
    
    func createTable() -> String? {
        return nil
    }
}
