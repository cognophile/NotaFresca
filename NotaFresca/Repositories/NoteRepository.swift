
import Foundation
import SQLite

class NoteRepository {
    private var data = [NoteModel]()
    private var model = NoteModel()
    private let database = DatabaseHelper()
    
    init() {
        self.database.createTable(model: self.model)
    }
    
    public func readAll() -> Array<NoteModel> {
        let records = Array(self.database.selectAll(model: self.model)!)
        var notes = [NoteModel]()
        
        for line in records {
            let note = self.rowToObject(record: line)
            notes.append(note)
        }
        
        return notes
    }
    
    public func readOne(target: Int) -> NoteModel {
        let record = self.database.selectOne(model: self.model, index: target)
        let note = self.rowToObject(record: record!)
        return note
    }
    
    public func save(note: NoteModel) -> NoteModel {
        let query = self.model.table!.insert(
            self.model.title <- note.data.title,
            self.model.body <- note.data.body,
            self.model.created <- note.data.created,
            self.model.updated <- note.data.updated
        )
        
        note.record = self.database.insert(model: self.model, query: query)
        return note
    }
    
    public func update(note: NoteModel) -> NoteModel {
        let query = [
            self.model.title <- note.data.title,
            self.model.body <- note.data.body,
            self.model.created <- note.data.created,
            self.model.updated <- note.data.updated
        ]
        
        note.record = self.database.update(model: self.model, index: note.getId(), query: query)
        return note
    }

    public func delete(target: Int) -> Bool {
        if let deletedId = self.database.delete(model: self.model, index: target) {
            return true
        }
        
        return false
    }
    
    private func rowToObject(record: Row) -> NoteModel {
        let note = NoteModel()
        
        note.record = record
        note.data.id = record[note.id]
        note.data.title = record[note.title]
        note.data.body = record[note.body]
        note.data.created = record[note.created]
        note.data.updated = record[note.updated]
        
        return note
    }
}
