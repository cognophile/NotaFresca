
import Foundation
import Cocoa

class NoteBrowserViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTableViewClickableDelegate, NoteEditorSyncDelegate {
    @IBOutlet weak var browser: NSTableView?
    @IBOutlet weak var search: NSSearchField?
    @IBOutlet var create: NSButton!
    @IBOutlet weak var remove: NSButton!
    
    var notes: Array<NoteModel>?
    var activeNote: NoteModel?
    var repository: NoteRepository?
    var editor: NoteEditorViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.repository = NoteRepository()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        
        self.browser?.delegate = self
        self.browser?.dataSource = self
        self.editor?.syncDelegate = self

        self.refresh()
    }
    
    @objc func refresh(_ notification: NSNotification? = nil) {
        let first : Int = 0
        self.notes = self.repository?.readAll()

        self.browser?.reloadData()
        self.browser?.selectRowIndexes(NSIndexSet(index: first) as IndexSet, byExtendingSelection: false)
        self.browser?.scrollRowToVisible(first)
        
        if (self.notes?.count ?? 0 > 0) {
            self.activeNote = self.notes?[first]
            self.editor?.render(index: (self.activeNote?.getId())!, note: (self.activeNote)!)
        }        
    }
    
    @IBAction func createNoteButton(_ sender: NSButton) {
        self.createNote()
    }
    
    @IBAction func removeNoteButton(_ sender: NSButton) {
        self.deleteNote()
    }
    
    func updateBrowser(_ sender: NoteEditorViewController) {
        self.refresh()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.notes?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 98
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let truncateLength = 64
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NoteBrowserCellView"), owner: self) as? NoteBrowserCellView
        
        guard let item = self.notes?[row] else {
            return nil
        }
        
        let body = item.getBody()
        cell?.title.stringValue = item.getTitle()
        cell?.bodyPreview.stringValue = (body.count > truncateLength) ? body.trunc(length: truncateLength) : body
        cell?.created.stringValue = item.getCreatedString()
        cell?.updated.stringValue = item.getUpdatedString()
        
        return cell
    }
    
    @nonobjc func tableView(_ tableView: NSTableView, didClickRow selectedRow: Int) {
        tableView.selectRowIndexes(NSIndexSet(index: selectedRow) as IndexSet, byExtendingSelection: false)
        tableView.scrollRowToVisible(selectedRow)
        
        if selectedRow > -1, selectedRow < self.notes?.count ?? 0 {
            self.activeNote = self.notes?[selectedRow]
            self.editor?.render(index: (self.activeNote?.getId())!, note: (self.activeNote)!)
        }
    }
    
    public func createNote() {
        let newNote = NoteModel()
        newNote.build(title: "Give it a great title...", body: "Now, let's get writing!")
        
        if let note = self.repository?.save(note: newNote) {
            self.refresh()
            self.editor?.render(index: note.getId(), note: note)
        }
    }
    
    public func deleteNote() {
        let isConfirmed = DialogHelper.confirm(header: "Woah there...", body: "You're about to permenantly delete this note. Are you sure you wish to proceed?")
        
        if (isConfirmed) {
            if let selectedIndex = browser?.selectedRow {
                let selectedNote = self.notes?[selectedIndex]
                
                if let isDeleted = self.repository?.delete(target: (selectedNote?.getId())!) {
                    self.refresh()
                    self.editor?.empty()
                }
            }
        }
    }
}
