
import Foundation
import Cocoa

class NoteBrowserCellView: NSTableCellView {
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var bodyPreview: NSTextField!
    @IBOutlet weak var created: NSTextField!
    @IBOutlet weak var updated: NSTextField!
}
