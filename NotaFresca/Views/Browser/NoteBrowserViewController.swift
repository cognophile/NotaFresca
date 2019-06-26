
import Foundation
import Cocoa

class NoteBrowserViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var browser: NSTableView?
    @IBOutlet weak var search: NSSearchField?
    @IBOutlet var create: NSButton!
    @IBOutlet weak var remove: NSButton!
    
    var notes: Array<NoteModel>?
    var activeNote: NoteModel?
    var respository: NoteRepository = NoteRepository()
    var editor: NoteEditorViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        
        browser?.delegate = self
        browser?.dataSource = self
        
        self.refresh()
    }
    
    @objc func refresh(_ notification: NSNotification? = nil) {
        let index : Int = 0
        self.notes = self.respository.readAll()
        self.editor?.setRepository(repository: self.respository)

        browser?.reloadData()
        browser?.selectRowIndexes(NSIndexSet(index: index) as IndexSet, byExtendingSelection: false)
        browser?.scrollRowToVisible(index)
        
        if (self.notes?.count ?? 0 > 0) {
            self.activeNote = self.notes?[index]
        }
    }
    
    @IBAction func createNoteButton(_ sender: NSButton) {
        let newNote = NoteModel(
            title: "New note",
            body: "Write something here..."
        )
        
        if let index = self.respository.save(note: newNote) {
            self.refresh()
            editor?.render(index: index, note: newNote)
        }
    }
    
    @IBAction func removeNoteButton(_ sender: NSButton) {
        if let selectedNote = browser?.selectedRow {
            self.respository.delete(target: selectedNote)
            self.refresh()
            editor?.empty()
        }
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
        
        cell?.title.stringValue = item.title;
        cell?.bodyPreview.stringValue = (item.body.count > truncateLength) ? item.body.trunc(length: truncateLength) : item.body
        cell?.created.stringValue = DateFormatHelper.toDateTime(date: item.created)
        
        return cell
    }
}
