
import Foundation

class I18nHelper {
    private var localeKey: String
    private var messages: [String: AnyObject]?

    init() {
        self.localeKey = NSLocale.preferredLanguages[0]
        self.loadFile()
    }

    public func locateMessage(category: String, key: String) -> String {
        if let message = self.messages![category] as? [String: AnyObject] {
            return (message[key] as? String)!
        }
        
        _ = DialogHelper.error(header: "Locale error", body: "Unfortunately, this language is not yet supported. Please request it by submitting an issue on the Github page. \nAlternatively, change your preferred language in your devices language settings.", error: nil)
        return ""
    }
    
    private func loadFile() {
        if let path = Bundle.main.path(forResource: "i18nContent", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                
                if let dictionary = object as? [String: AnyObject] {
                    self.messages = dictionary[self.localeKey] as? [String: AnyObject]
                }
            } catch {
                _ = DialogHelper.error(header: "Rut-roh!", body: "Unexpected error when initialising. If this continues, please submit an issue on GitHub", error: error)
            }
        }
    }
}
