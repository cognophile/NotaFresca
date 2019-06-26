
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
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy @ hh:mm"
        return formatter.string(from: self.created)
    }
}
