
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
        let casted = self.downcast(data: item.data)
        
        let query = self.noteModel.table!.insert(
            self.noteModel.title <- casted.title,
            self.noteModel.body <- casted.body,
            self.noteModel.created <- casted.created,
            self.noteModel.updated <- casted.updated
        )
        
        item.record = self.database.insert(model: self.noteModel, query: query)
        return item
    }
    
    public override func update(target: BaseModel) -> BaseModel {
        let casted = self.downcast(data: target.data)
        
        let query = [
            self.noteModel.title <- casted.title,
            self.noteModel.body <- casted.body,
            self.noteModel.created <- casted.created,
            self.noteModel.updated <- casted.updated
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
