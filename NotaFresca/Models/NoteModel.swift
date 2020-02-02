
import Foundation
import SQLite

class NoteModel: BaseModel {
    let title = Expression<String?>("title")
    let body = Expression<String?>("body")
    let created = Expression<String?>("created")
    let updated = Expression<String?>("updated")
    
    // var data: NoteDataStruct = NoteDataStruct()

    override init() {
        super.init()
        self.table = Table("notes")
    }
    
    public override func getId() -> Int {
        return try! (record?.get(self.id))!
    }
    
    public func getTitle() -> String {
        return try! (record?.get(self.title))!
    }
    
    public func getBody() -> String {
        return try! (record?.get(self.body))!
    }
    
    public func getCreatedString() -> String {
        let created = try! (record?.get(self.created))!
        return created 
    }
    
    public func getUpdatedString() -> String {
        let updated = try! (record?.get(self.updated))!
        return updated
    }
    
    override func createTable() -> String {
        return (self.table?.create(ifNotExists: true) {
            t in
                t.column(self.id, primaryKey: true)
                t.column(self.title)
                t.column(self.body)
                t.column(self.created)
                t.column(self.updated)
            })!
    }
    
    public func build(title: String, body: String) {
        let created = DateFormatHelper.toDateTimeString(date: Date())
        let updated = created
        
        self.data.title = title
        self.data.body = body
        self.data.created = created
        self.data.updated = updated
    }
    
    public func modify(title: String, body: String, created: String, updated: String) {
        self.data.title = title
        self.data.body = body
        self.data.created = created
        self.data.updated = updated
    }
}
