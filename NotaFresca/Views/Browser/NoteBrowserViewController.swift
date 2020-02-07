
import Foundation
import Cocoa

class NoteBrowserViewController: BaseViewController, NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate, NSTableViewClickableDelegate, NoteEditorSyncDelegate {
    @IBOutlet weak var browser: NSTableView?
    @IBOutlet weak var search: NSSearchField?
    @IBOutlet var create: NSButton!
    @IBOutlet weak var remove: NSButton!
    @IBOutlet weak var trash: NSButton!
    
    var notes: Array<NoteModel>?
    var selectedIndex: Int?
    var isSearching: Bool = false
    var showTrash: Bool = false
    var activeNote: NoteModel?
    var repository: BaseRepository?
    var editor: NoteEditorViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        
        self.repository = NoteRepository()
        
        self.browser?.delegate = self
        self.browser?.dataSource = self
        self.search?.delegate = self
        self.editor?.syncDelegate = self

        self.refreshBrowserSelection()
    }
    
    @objc func refresh(_ notification: NSNotification? = nil) {
        let defaultIndex = 0
        self.setBrowserContent()
                    
        if let selected = self.selectedIndex {
            self.browser?.reloadData()
            self.browser?.selectRowIndexes(NSIndexSet(index: selected) as IndexSet, byExtendingSelection: false)
            self.browser?.scrollRowToVisible(selected)
            
            if (self.notes?.count ?? 0 > 0 && self.selectedIndex ?? 0 <= self.notes?.count ?? 0) {
                self.activeNote = self.notes?[selected]
                self.editor?.render(index: (self.activeNote?.getId())!, note: (self.activeNote)!)
            }
            else {
                self.selectedIndex = 0
                self.activeNote = self.notes?[self.selectedIndex!]
                self.editor?.render(index: (self.activeNote?.getId())!, note: (self.activeNote)!)
            }
        }
        else {
            self.browser?.reloadData()
            self.browser?.selectRowIndexes(NSIndexSet(index: defaultIndex) as IndexSet, byExtendingSelection: false)
            self.browser?.scrollRowToVisible(defaultIndex)
        }
    }
    
    @IBAction func createNoteButton(_ sender: NSButton) {
        self.createNote()
    }
    
    @IBAction func removeNoteButton(_ sender: NSButton) {
        self.trashNote()
    }
    
    @IBAction func showTrashButton(_ sender: NSButton) {
        self.displayTrash()
    }
    
    func updateBrowser(_ sender: NoteEditorViewController) {
        self.refreshBrowserSelection()
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
        if selectedRow > -1, selectedRow < self.notes?.count ?? 0 {
            self.activeNote = self.notes?[selectedRow]
            self.editor?.render(index: (self.activeNote?.getId())!, note: (self.activeNote)!)
            self.refreshBrowserSelection(indexToHighlight: selectedRow)
        }
    }
    
    public func createNote() {
        let newNote = NoteModel()
        newNote.build(
            title: self.i18n!.locateMessage(category: "Templates", key: "Note.Title"),
            body: self.i18n!.locateMessage(category: "Templates", key: "Note.Body")
        )
        
        if let note = self.repository?.save(item: newNote) {
            self.refreshBrowserSelection(indexToHighlight: self.notes?.count ?? 0)
            self.editor?.render(index: note.getId()!, note: note as! NoteModel)
        }
    }
    
    public func restoreNote() {
        if let selectedIndex = browser?.selectedRow {
            let selectedNote = self.notes?[selectedIndex]
            
            if let isRestored = self.repository?.restore(target: (selectedNote?.getId())!) {
                if self.selectedIndex ?? 0 > 0 {
                    self.selectedIndex? -= 1
                }
                self.refreshBrowserSelection()
                self.editor?.empty()
            }
        }
    }
    
    public func trashNote() {
        var isConfirmed: Bool = false
        
        if self.showTrash {
            isConfirmed = DialogHelper.confirm(
                header: self.i18n!.locateMessage(category: "Headers", key: "Warning"),
                body: self.i18n!.locateMessage(category: "Body", key: "Confirm.Delete")
            )
        }
        else {
            isConfirmed = DialogHelper.confirm(
                header: self.i18n!.locateMessage(category: "Headers", key: "Warning"),
                body: self.i18n!.locateMessage(category: "Body", key: "Confirm.Trash")
            )
        }

        if (isConfirmed) {
            if let selectedIndex = browser?.selectedRow {
                let selectedNote = self.notes?[selectedIndex]
                
                if let isTrashed = self.repository?.delete(target: (selectedNote?.getId())!) {
                    if self.selectedIndex ?? 0 > 0 {
                        self.selectedIndex? -= 1
                    }
                    self.refreshBrowserSelection()
                    self.editor?.empty()
                }
            }
        }
    }
    
    public func displayTrash() -> Void {
        if (!self.showTrash) {
            self.showTrash = true
            self.refreshBrowserSelection()
        }
        else {
            self.showTrash = false
            self.refreshBrowserSelection()
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if obj.object as? NSSearchField == self.search {
            self.searchNotes(self.search?.stringValue ?? "")
        }
    }
    
    public func emptyTrash() -> Void {
        if !self.showTrash {
            _ = DialogHelper.notice(
                header: self.i18n!.locateMessage(category: "Headers", key: "Warning"),
                body: self.i18n!.locateMessage(category: "Information", key: "Trash.Empty")
            )
            
            return
        }
        
        let isConfirmed = DialogHelper.confirm(
            header: self.i18n!.locateMessage(category: "Headers", key: "Warning"),
            body: self.i18n!.locateMessage(category: "Body", key: "Confirm.DeleteAll")
        )
                
        if isConfirmed, let _ = self.repository?.deleteAll() {
            self.refreshBrowserSelection()
        }
    }
    
    private func searchNotes(_ searchTerm: String) {
        var results = [NoteModel]()
        
        if searchTerm.count > 0 {
            self.isSearching = true
            results = (self.repository?.find(term: searchTerm, items: self.notes!)) as! [NoteModel]
            
            if results.count <= 0 {
                self.editor?.empty()
            }
            
            self.notes = results
        }
        else {
            self.isSearching = false
        }
        
        self.browser?.reloadData()
        self.refreshBrowserSelection(indexToHighlight: 0)
    }
    
    private func refreshBrowserSelection(indexToHighlight: Int? = nil) {
        if let selected = indexToHighlight {
            self.selectedIndex = selected
        }
        
        return self.refresh()
    }
    
    private func setBrowserContent() {
        if self.isSearching {
            return
        }
        
        if self.showTrash {
            self.repository = NoteTrashRepository()
            self.notes = self.repository?.readAll() as? Array<NoteModel>
        }
        else {
            self.repository = NoteRepository()
            self.notes = self.repository?.readAll() as? Array<NoteModel>
        }
    }
}
