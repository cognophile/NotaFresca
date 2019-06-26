
import Foundation

class NoteRepository {
    private var data = [NoteModel]()
    
    init() {}
    
    public func save(note: NoteModel) -> Int? {
        self.data.append(note)
        
        if let index = self.data.firstIndex(of: note) {
            return index
        }
        
        return nil
    }
    
    public func update(target: Int, note: NoteModel) {
        self.data[target] = note
    }
    
    public func delete(target: Int) {
        self.data.remove(at: target)
    }
    
    public func readAll() -> Array<NoteModel> {
        return self.data
    }
    
    public func readOne(at: Int) -> NoteModel {
        return self.data[at]
    }
}
