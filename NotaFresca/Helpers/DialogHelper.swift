
import Foundation
import Cocoa

class DialogHelper {
    public static func confirm(header: String, body: String) -> Bool {
        let dialog = self.createDialog()
        
        dialog.messageText = header
        dialog.informativeText = body
        
        dialog.alertStyle = .warning
        dialog.addButton(withTitle: "Delete")
        dialog.addButton(withTitle: "Cancel")
        
        return dialog.runModal() == .alertFirstButtonReturn
    }
    
    private static func createDialog() -> NSAlert {
        return NSAlert()
    }
}
