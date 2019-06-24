
import Foundation
import Cocoa
import Down

class NoteEditorViewController: NSViewController {
    @IBOutlet weak var titleLabel: NSTextField?
    @IBOutlet weak var bodyLabel: NSTextField?
    @IBOutlet weak var createdLabel: NSTextField?
    @IBOutlet weak var bodyPane: NSScrollView!
    @IBOutlet weak var titlePane: NSTextField!
    
    var note: NoteModel?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideLabels(visibility: true)
    }
    
    public func showNote(note: NoteModel) {
        self.note = note
        
        self.hideLabels(visibility: false)
       
        self.titlePane?.stringValue = self.note!.title
        self.bodyPane?.documentView!.insertText(self.note!.body)
        self.createdLabel?.stringValue = self.note!.created
    }
    
    private func hideLabels(visibility: Bool) {
        self.titlePane.isHidden = visibility
        self.bodyPane?.isHidden = visibility
        self.createdLabel?.isHidden = visibility
    }
}
