
import Foundation
import Cocoa

class NoteViewController: NSSplitViewController {
    @IBOutlet weak var browser: NSSplitViewItem!
    @IBOutlet weak var editor: NSSplitViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let browserController = browser.viewController as? NoteBrowserViewController
        let editorController = editor.viewController as? NoteEditorViewController
        browserController?.editor = editorController
    }
    
    override var representedObject: Any? {
        didSet {
        }
    }
}
