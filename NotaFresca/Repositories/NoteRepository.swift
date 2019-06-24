
import Foundation

class NoteRepository {
    private var data = [NoteModel]()
    
    init() {
        let newNote = NoteModel(
            title: "My test note",
            body: "I'm a test listed note"
        )
        
        self.save(note: newNote)
    }
    
    public func save(note: NoteModel) {
        self.data.append(note)
    }
    
    public func read() -> Array<NoteModel> {
        return self.data
    }
}
