
import Foundation
import SQLite

class NoteRepository: BaseRepository {
    private var data = [NoteModel]()
    private var noteModel = NoteModel()
    private var trashModel = NoteTrashModel()
    private var trashRepository = NoteTrashRepository()
    
    override init() {
        super.init()
        self.database.createTable(model: self.noteModel)
    }
    
    public override func readAll() -> Array<BaseModel> {
        guard let statement = noteModel.table?
                .select(self.noteModel.table![*])
                .join(.leftOuter, self.trashModel.table!, on: self.trashModel.noteId == self.noteModel.table![self.noteModel.id])
                .filter(self.trashModel.table![self.trashModel.optId] == nil)
            else {
                return Array<NoteModel>()
        }

        let records = Array(self.database.selectAll(model: self.noteModel, override: statement)!)
        let notes = self.transformMultipleRows(rows: records)
        
        return notes
    }
    
    public override func readOne(target: Int) -> BaseModel {
        guard let statement = noteModel.table?
                .select(self.noteModel.table![*]).join(.leftOuter, self.trashModel.table!, on: self.trashModel.noteId == self.noteModel.table![self.noteModel.id])
                .filter(self.trashModel.table![self.trashModel.optId] == nil)
                .filter(self.noteModel.table![self.noteModel.optId] == target)
            else {
                return NoteModel()
        }
        
        let record = self.database.selectOne(model: self.noteModel, index: target, override: statement)
        let note = self.transformRow(row: record!)
        
        return note
    }
    
    public override func save(item: BaseModel) -> BaseModel {
        let query = self.noteModel.table!.insert(
            self.noteModel.title <- item.data.title,
            self.noteModel.body <- item.data.body,
            self.noteModel.created <- item.data.created,
            self.noteModel.updated <- item.data.updated
        )
        
        item.record = self.database.insert(model: self.noteModel, query: query)
        return item
    }
    
    public override func update(target: BaseModel) -> BaseModel {
        let query = [
            self.noteModel.title <- target.data.title,
            self.noteModel.body <- target.data.body,
            self.noteModel.created <- target.data.created,
            self.noteModel.updated <- target.data.updated
        ]
        
        target.record = self.database.update(model: self.noteModel, index: target.getId()!, query: query)
        return target
    }

    public override func delete(target: Int) -> Bool {
        let isTrashed = self.trashRepository.trash(noteId: target)
        
        if ((isTrashed) != nil) {
            return true
        }
        
        return false
    }
    
    public override func find(term: String, items: [BaseModel]) -> Array<BaseModel> {
        let loweredTerm = term.lowercased()
        let results = items.filter { item in return
            ((item.data.title?.lowercased().contains(loweredTerm))!) || ((item.data.body?.lowercased().contains(loweredTerm))!)
        }
        
        return results
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
