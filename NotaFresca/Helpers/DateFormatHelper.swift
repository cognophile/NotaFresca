import Foundation

class DateFormatHelper {
    static func toDateTimeString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy @ HH:mm"
        return formatter.string(from: date)
    }
}
