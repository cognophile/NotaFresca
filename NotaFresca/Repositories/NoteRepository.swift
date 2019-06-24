
import Foundation

class NoteRepository {
    private var data = [NoteModel]()
    
    init() {}
    
    public func save(note: NoteModel) {
        self.data.append(note)
    }
    
    public func read() -> Array<NoteModel> {
        return self.data
    }
}
