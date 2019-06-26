
import Foundation

class DateFormatHelper {
    static func toDateTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy @ hh:mm"
        return formatter.string(from: date)
    }
}
