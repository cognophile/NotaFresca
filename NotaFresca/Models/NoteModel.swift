
import Foundation

public struct NoteModel {
    let title: String
    let body: String
    let created: String
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
        
        let created = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy @ hh:mm"
        self.created = formatter.string(from: created)
    }
}
