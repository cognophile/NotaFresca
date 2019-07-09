
import Foundation

class BaseRepository {
    let database = DatabaseHelper()
    
    func readAll() -> Array<BaseModel>? {
        return nil
    }
    
    func readOne() -> BaseModel? {
        return nil
    }
    
    func save() -> BaseModel? {
        return nil
    }
    
    func update()  -> BaseModel? {
        return nil
    }
    
    func delete() -> Bool? {
        return false
    }
    
    func find() -> Array<BaseModel>? {
        return nil
    }
}
