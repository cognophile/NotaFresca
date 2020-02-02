
import Foundation
import Cocoa

class NoteViewController: NSSplitViewController {
    @IBOutlet weak var browser: NSSplitViewItem!
    @IBOutlet weak var editor: NSSplitViewItem!
    
    var browserController: NoteBrowserViewController?
    var editorController: NoteEditorViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.browserController = self.browser.viewController as? NoteBrowserViewController
        self.editorController = self.editor.viewController as? NoteEditorViewController

        self.editorController?.syncDelegate = self.browserController
        self.browserController?.editor = self.editorController
    }
    
    override var representedObject: Any? {
        didSet {
        }
    }
    
    @IBAction func menuNewNote(_ sender: Any) {
        self.browserController?.createNote()
    }
    
    @IBAction func menuTrashNote(_ sender: Any) {
        self.browserController?.trashNote()
    }
    
    @IBAction func menuViewTrash(_ sender: Any) {
        self.browserController?.displayTrash()
    }
    
    @IBAction func menuRestoreNote(_ sender: Any) {
        self.browserController?.restoreNote()
    }
}
