
import Foundation
import Cocoa

class NoteEditorViewController: BaseViewController, NSTextViewDelegate, NSTextFieldDelegate {
    @IBOutlet weak var createdLabel: NSTextField?
    @IBOutlet weak var bodyPane: NSScrollView!
    @IBOutlet weak var bodyTextView: NSTextView!
    @IBOutlet weak var titlePane: NSTextField!
    @IBOutlet weak var updatedLabel: NSTextField!
    
    private let TIME_DELAY_FACTOR: Double = 0.8
    
    var activeNote: NoteModel?
    var repository: NoteRepository?
    var browserIndex: Int?
    var timer: Timer? = Timer()

    weak var syncDelegate: NoteEditorSyncDelegate?
    
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
        timer = Timer.scheduledTimer(timeInterval: self.TIME_DELAY_FACTOR, target: self, selector: #selector(self.updateNoteTitle), userInfo: textField.stringValue, repeats: false)
    }
    
    public func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView, self.bodyTextView.identifier == textView.identifier, self.bodyTextView.string == textView.string else {
            return
        }

        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: self.TIME_DELAY_FACTOR, target: self, selector: #selector(self.updateNoteBody), userInfo: textView.string, repeats: false)
    }
    
    @objc private func updateNoteTitle() {
        let updated = DateFormatHelper.toDateTimeString(date: Date())
        
        if self.activeNote != nil {
            self.activeNote?.modify(title: self.timer?.userInfo as! String, body: (self.activeNote?.getBody())!, created: (self.activeNote?.getCreatedString())!, updated: updated)
            
            if let edited = self.repository?.update(note: self.activeNote!) {
                self.activeNote = self.repository?.readOne(target: self.browserIndex!)
            }
            
            self.syncDelegate?.updateBrowser(self)
            self.timer?.invalidate()
        }
    }
    
    @objc private func updateNoteBody() {
        let updated = DateFormatHelper.toDateTimeString(date: Date())
        
        if self.activeNote != nil {
            self.activeNote?.modify(title: (self.activeNote?.getTitle())!, body: self.timer?.userInfo as! String, created: (self.activeNote?.getCreatedString())!, updated: updated)
            
            if let edited = self.repository?.update(note: self.activeNote!) {
                self.activeNote = self.repository?.readOne(target: self.browserIndex!)
            }
            
            self.syncDelegate?.updateBrowser(self)
            self.timer?.invalidate()
        }
    }
    
    private func hideLabels(hide: Bool) {
        self.titlePane.isHidden = hide
        self.bodyPane.isHidden = hide
        self.createdLabel?.isHidden = hide
        self.updatedLabel?.isHidden = hide
    }
    
    private func setActiveNote(index: Int?, note: NoteModel?) {
        self.browserIndex = index
        self.activeNote = note
    }
    
    private func displayNote() {
        self.titlePane.stringValue = self.activeNote?.getTitle() ?? ""
        self.bodyTextView.string = "";
        self.bodyPane.documentView!.insertText(self.activeNote?.getBody() ?? "")
        self.createdLabel?.stringValue = self.activeNote?.getCreatedString() ?? ""
        self.updatedLabel?.stringValue = self.activeNote?.getUpdatedString() ?? ""
    }
}
