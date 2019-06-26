
import Foundation

public struct NoteModel: Equatable {
    let title: String
    let body: String
    let created: Date
    
    init(title: String, body: String, created: Date = Date()) {
        self.title = title
        self.body = body
        self.created = created
    }
    
    public func getCreatedString() -> String {
        return DateFormatHelper.toDateTime(date: self.created)
    }
}
