
import Foundation
import SQLite

class NoteRepository: BaseRepository {
    private var data = [NoteModel]()
    private var model = NoteModel()
    
    override init() {
        super.init()
        self.database.createTable(model: self.model)
    }
    
    public func readAll() -> Array<NoteModel> {
        let records = Array(self.database.selectAll(model: self.model)!)
        let notes = self.transformMultipleRows(rows: records)
        
        return notes
    }
    
    public func readOne(target: Int) -> NoteModel {
        let record = self.database.selectOne(model: self.model, index: target)
        let note = self.transformRow(row: record!)
        
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
        if self.database.delete(model: self.model, index: target) != nil {
            return true
        }
        
        return false
    }
    
    public func find(term: String, notes: [NoteModel]) -> Array<NoteModel> {
        let notes = Array(self.database.selectAll(model: self.model)!)
        
        let results = notes.filter { item in return
            (item[self.model.title]?.lowercased().contains(term.lowercased()))! ||
            (item[self.model.body]?.lowercased().contains(term.lowercased()))!
        }
        
        return self.transformMultipleRows(rows: results)
    }
    
    private func transformMultipleRows(rows: [Row]) -> [NoteModel] {
        var notes = [NoteModel]()
        
        for line in rows {
            let noteObject = self.transformRow(row: line)
            notes.append(noteObject)
        }
        
        return notes
    }
    
    private func transformRow(row: Row) -> NoteModel {
        let note = NoteModel()
        
        note.record = row
        note.data.id = row[note.id]
        note.data.title = row[note.title]
        note.data.body = row[note.body]
        note.data.created = row[note.created]
        note.data.updated = row[note.updated]
        
        return note
    }
}
