
import Foundation
import Cocoa
import Down

class NoteEditorViewController: NSViewController {
    @IBOutlet weak var titleLabel: NSTextField?
    @IBOutlet weak var bodyLabel: NSTextField?
    @IBOutlet weak var createdLabel: NSTextField?
    
    var note: NoteModel?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.isHidden = true;
        self.bodyLabel?.isHidden = true;
        self.createdLabel?.isHidden = true;
    }
    
    public func showNote(note: NoteModel) {
        self.note = note
        
        self.titleLabel?.stringValue = self.note!.title
        self.bodyLabel?.stringValue = self.note!.body
        self.createdLabel?.stringValue = self.note!.created
        
        self.titleLabel?.isHidden = false;
        self.bodyLabel?.isHidden = false;
        self.createdLabel?.isHidden = false;
    }
}
