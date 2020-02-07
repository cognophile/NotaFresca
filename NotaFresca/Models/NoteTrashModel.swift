
import Foundation
import SQLite

class NoteTrashModel: BaseModel {
    let noteId = Expression<Int>("note_id")
    let deletedDatetime = Expression<String?>("deleted_datetime")
    
    override init() {
        super.init()
        self.table = Table("note_trash")
    }
    
    override func createTable() -> String? {
        let foreignTable = NoteModel()

        return (self.table?.create(ifNotExists: true) {
            t in
                t.column(self.id, primaryKey: true)
                t.column(self.noteId)
                t.column(self.deletedDatetime)
                t.foreignKey(self.noteId, references: foreignTable.table!, foreignTable.id, update: .cascade, delete: .cascade)
        })!
    }
}
