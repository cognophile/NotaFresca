
import Foundation
import Cocoa
import Down

class NoteEditorViewController: NSViewController, NSTextViewDelegate, NSTextFieldDelegate {
    @IBOutlet weak var titleLabel: NSTextField?
    @IBOutlet weak var bodyLabel: NSTextField?
    @IBOutlet weak var createdLabel: NSTextField?
    @IBOutlet weak var bodyPane: NSScrollView!
    @IBOutlet weak var bodyTextView: NSTextView!
    @IBOutlet weak var titlePane: NSTextField!
    @IBOutlet weak var updatedLabel: NSTextField!
    
    var note: NoteModel?
    var repository: NoteRepository?
    var browserIndex: Int?
    var timer: Timer? = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.repository = NoteRepository()
        
        self.bodyTextView.delegate = self
        self.titlePane.delegate = self
        self.bodyPane.documentView = self.bodyTextView
        self.bodyPane.contentView.scroll(to: .zero)
        
        self.hideLabels(hide: true)
    }
    
    public func render(index: Int, note: NoteModel) {
        self.setActiveNote(index: index, note: note)
        self.hideLabels(hide: false)
        self.displayNote()
    }
    
    public func empty() {
        self.setActiveNote(index: nil, note: nil)
        self.hideLabels(hide: true)
    }
    
    public func controlTextDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField, self.titlePane.identifier == textField.identifier else {
            return
        }

        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.updateNoteTitle), userInfo: textField.stringValue, repeats: false)
    }
    
    public func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView, self.bodyTextView.identifier == textView.identifier else {
            return
        }

        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.updateNoteBody), userInfo: textView.string, repeats: false)
    }
    
    @objc private func updateNoteTitle() {
        let updated = DateFormatHelper.toDateTimeString(date: Date())
        self.note?.modify(title: self.timer?.userInfo as! String, body: (self.note?.getBody())!, created: (self.note?.getCreatedString())!, updated: updated)
        
        if let edited = self.repository?.update(note: self.note!) {
            self.note = self.repository?.readOne(target: self.browserIndex!)
        }

        self.timer?.invalidate()
    }
    
    @objc private func updateNoteBody() {
        let updated = DateFormatHelper.toDateTimeString(date: Date())
        self.note?.modify(title: (self.note?.getTitle())!, body: self.timer?.userInfo as! String, created: (self.note?.getCreatedString())!, updated: updated)
        
        if let edited = self.repository?.update(note: self.note!) {
            self.note = self.repository?.readOne(target: self.browserIndex!)
        }

        self.timer?.invalidate()
    }
    
    private func hideLabels(hide: Bool) {
        self.titlePane.isHidden = hide
        self.bodyPane.isHidden = hide
        self.createdLabel?.isHidden = hide
        self.updatedLabel?.isHidden = hide
    }
    
    private func setActiveNote(index: Int?, note: NoteModel?) {
        self.browserIndex = index
        self.note = note
    }
    
    private func displayNote() {
        self.titlePane.stringValue = self.note?.getTitle() ?? ""
        self.bodyTextView.string = "";
        self.bodyPane.documentView!.insertText(self.note?.getBody() ?? "")
        self.createdLabel?.stringValue = self.note?.getCreatedString() ?? ""
        self.updatedLabel?.stringValue = self.note?.getUpdatedString() ?? ""
    }
}
