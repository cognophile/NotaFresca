
import Foundation
import Cocoa
import Down

class NoteEditorViewController: NSViewController, NSTextViewDelegate, NSTextFieldDelegate {
    @IBOutlet weak var titleLabel: NSTextField?
    @IBOutlet weak var bodyLabel: NSTextField?
    @IBOutlet weak var createdLabel: NSTextField?
    @IBOutlet weak var bodyPane: NSScrollView!
    @IBOutlet weak var bodyContainedTextView: NSTextView!
    @IBOutlet weak var titlePane: NSTextField!
    
    var note: NoteModel?
    var browserIndex: Int?
    var repository: NoteRepository?
    var timer: Timer? = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bodyContainedTextView.delegate = self
        self.titlePane.delegate = self
        self.bodyPane.documentView = self.bodyContainedTextView
        self.bodyPane.contentView.scroll(to: .zero)
        
        self.hideLabels(hide: true)
    }
    
    public func setRepository(repository: NoteRepository) {
        self.repository = repository
    }
    
    public func render(index: Int, note: NoteModel) {
        self.setActiveNote(index: index, note: note)
        self.hideLabels(hide: false)
       
        self.setDisplayNote(title: self.note!.title, body: self.note!.body, created: self.note!.created)
    }
    
    public func empty() {
        self.setActiveNote(index: nil, note: nil)
        self.hideLabels(hide: true)

        self.setDisplayNote(title: "", body: "", created: Date())
    }
    
    public func controlTextDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField, self.titlePane.identifier == textField.identifier else {
            return
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.updateNoteTitle), userInfo: textField.stringValue, repeats: false)
    }
    
    public func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView, self.bodyContainedTextView.identifier == textView.identifier else {
            return
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.updateNoteBody), userInfo: textView.string, repeats: false)
    }
    
    @objc private func updateNoteTitle() {
        if let editedNote = NoteModel(title: self.timer?.userInfo as! String, body: self.note!.body, created: self.note!.created) as? NoteModel {
            self.repository?.update(target: self.browserIndex!, note: editedNote)
            self.note = self.repository?.readOne(at: self.browserIndex!)
        }

        self.timer?.invalidate()
    }
    
    @objc private func updateNoteBody() {
        if let editedNote = NoteModel(title: self.note!.title, body: self.timer?.userInfo as! String) as? NoteModel {
            self.repository?.update(target: self.browserIndex!, note: editedNote)
            self.note = self.repository?.readOne(at: self.browserIndex!)
        }
        
        self.timer?.invalidate()
    }
    
    private func hideLabels(hide: Bool) {
        self.titlePane.isHidden = hide
        self.bodyPane.isHidden = hide
        self.createdLabel?.isHidden = hide
    }
    
    private func setActiveNote(index: Int?, note: NoteModel?) {
        self.browserIndex = index
        self.note = note
    }
    
    private func setDisplayNote(title: String, body: String, created: Date) {
        self.titlePane.stringValue = title
        self.bodyPane.documentView!.insertText(body)
        self.createdLabel?.stringValue = self.note!.getCreatedString()
    }
}
