
import Foundation
import SQLite

class NoteTrashRepository: BaseRepository {
    private var trashModel = NoteTrashModel()
    private var noteModel = NoteModel()
    
    override init() {
        super.init()
        self.database.createTable(model: self.trashModel)
    }
    
    public override func readAll() -> Array<BaseModel>? {
        guard let statement = noteModel.table?
                .select(self.noteModel.table![*])
                .join(.inner, self.trashModel.table!, on: self.trashModel.noteId == self.noteModel.table![self.noteModel.id])
//                .filter(self.trashModel.table![self.trashModel.optId] != nil)
            else {
                return Array<NoteModel>()
        }

        let records = Array(self.database.selectAll(model: self.noteModel, override: statement)!)
        let notes = self.transformMultipleRows(rows: records)
        
        return notes
    }
    
    public func trash(noteId: Int) -> Row? {
        let trashed = DateFormatHelper.toDateTimeString(date: Date())
        
        let query = self.trashModel.table!.insert(
            self.trashModel.noteId <- noteId,
            self.trashModel.deletedDatetime <- trashed
        )
        
        if let result = self.database.insert(model: self.trashModel, query: query) {
            return result
        }
        
        return nil
    }
    
    public override func delete(target: Int) -> Bool {
        let trashDeleted = self.database.delete(model: self.trashModel, index: target)
        let noteDeleted = self.database.delete(model: self.noteModel, index: target)
        
        if ((trashDeleted) != nil && (noteDeleted) != nil) {
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
