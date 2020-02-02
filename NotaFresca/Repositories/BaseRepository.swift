
import Foundation

class BaseRepository {
    let database = DatabaseHelper()
    
    func readAll() -> Array<BaseModel>? {
        return nil
    }
    
    func readOne(target: Int) -> BaseModel? {
        return nil
    }
    
    func save(item: BaseModel) -> BaseModel? {
        return nil
    }
    
    func update(target: BaseModel)  -> BaseModel? {
        return nil
    }
    
    func delete(target: Int) -> Bool? {
        return false
    }
    
    func find(term: String, items: Array<BaseModel>) -> Array<BaseModel>? {
        return nil
    }
}
