
import Foundation
import Cocoa

class DialogHelper {
    public static func confirm(header: String, body: String) -> Bool {
        let dialog = self.createDialog()
        let i18n = self.initialiseI18n()
        
        dialog.messageText = header
        dialog.informativeText = body
        
        dialog.alertStyle = NSAlert.Style.warning
        dialog.addButton(withTitle: i18n.locateMessage(category: "Buttons", key: "Remove"))
        dialog.addButton(withTitle: i18n.locateMessage(category: "Buttons", key: "Cancel"))
        
        return dialog.runModal() == .alertFirstButtonReturn
    }
    
    public static func error(header: String, body: String) -> Bool {
        let dialog = self.createDialog()
        let i18n = self.initialiseI18n()
        
        dialog.messageText = header
        dialog.informativeText = body
        
        dialog.alertStyle = NSAlert.Style.critical
        dialog.addButton(withTitle: i18n.locateMessage(category: "Buttons", key: "Continue"))
        
        return dialog.runModal() == .alertFirstButtonReturn
    }
    
    private static func createDialog() -> NSAlert {
        return NSAlert()
    }
    
    private static func initialiseI18n() -> I18nHelper {
        return I18nHelper()
    }
}
