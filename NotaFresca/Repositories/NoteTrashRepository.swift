
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
        guard let query = noteModel.table?
                .select(self.noteModel.table![*])
                .join(.inner, self.trashModel.table!, on: self.trashModel.noteId == self.noteModel.table![self.noteModel.id])
            else {
                return Array<NoteModel>()
        }

        let records = Array(self.database.selectAll(model: self.noteModel, override: query)!)
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
    
    public override func restore(target: Int) -> Int? {
        let query = self.trashModel.table?.filter(self.trashModel.noteId == target)
        let record = self.database.selectOne(model: self.trashModel, index: target, override: query)!
        
        do {
            if let result = self.database.delete(model: self.trashModel, index: try record.get(self.trashModel.id)) {
                return result
            }
        }
        catch  {
            _ = DialogHelper.error(header: "Error", body: "Restore.Unknown", error: error)
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
    
    public func getCount() -> Int {
        return self.readAll()?.count ?? 0
    }
    
    public override func deleteAll() -> Bool? {
        let trashed = self.readAll()!
        
        if let trashEmptied = self.database.deleteAll(model: self.trashModel) {
            for note in trashed {
                _ = self.database.delete(model: self.noteModel, index: note.getId()!)
            }
            
            return true
        }
        
        return false
    }
    
    public override func find(term: String, items: [BaseModel]) -> Array<BaseModel> {
        let loweredTerm = term.lowercased()
                    
        let results = items.filter { item in
            let data = self.downcast(data: item.data)
            if (data.title!.lowercased().contains(loweredTerm)) || (data.body!.lowercased() as AnyObject).contains(loweredTerm) {
                return true
            }
            
            return false
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
        
        let data = NoteDataObject()
        data.id = row[note.id]
        data.title = row[note.title]
        data.body = row[note.body]
        data.created = row[note.created]
        data.updated = row[note.updated]
        
        note.data = data
        note.record = row
        
        return note
    }
    
    private func downcast(data: BaseDataObject) -> NoteDataObject {
        let casted: NoteDataObject = NoteDataObject()
        
        if let temp = data as? NoteDataObject {
            casted.id = temp.id
            casted.title = temp.title
            casted.body = temp.body
            casted.created = temp.created
            casted.updated = temp.updated
        }
        
        return casted
    }
}
