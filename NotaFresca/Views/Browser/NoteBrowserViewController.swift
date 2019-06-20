
import Foundation
import Cocoa

class NoteBrowserViewController: NSViewController, NSTableViewDelegate {
    @IBOutlet weak var browser: NSTableView!
    @IBOutlet weak var search: NSSearchField!
    @IBOutlet var create: NSButton!
    
    var editor : NoteEditorViewController?

    @IBAction func createNoteButton(_ sender: NSButton) {
        editor?.showNote(note: NoteModel(
                title: "An Awesome Note",
                body: "Let's write!"
            )
        )
    }
}
