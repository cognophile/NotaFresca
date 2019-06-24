
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
        
        self.hideLabels(visibility: true)
    }
    
    public func showNote(note: NoteModel) {
        self.note = note
        
        self.titleLabel?.stringValue = self.note!.title
        self.bodyLabel?.stringValue = self.note!.body
        self.createdLabel?.stringValue = self.note!.created
        
        self.hideLabels(visibility: false)
    }
    
    private func hideLabels(visibility: Bool) {
        self.titleLabel?.isHidden = visibility;
        self.bodyLabel?.isHidden = visibility;
        self.createdLabel?.isHidden = visibility;
    }
}
