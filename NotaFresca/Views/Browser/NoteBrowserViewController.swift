
import Foundation
import Cocoa

class NoteBrowserViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var browser: NSTableView?
    @IBOutlet weak var search: NSSearchField?
    @IBOutlet var create: NSButton!
    
    var editor: NoteEditorViewController?
    var notes: Array<NoteModel>?
    var activeNote: NoteModel?
    var respository: NoteRepository = NoteRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        
        browser?.delegate = self
        browser?.dataSource = self
        
        self.refresh()
    }
    
    @objc func refresh(_ notification: NSNotification? = nil) {
        let index : Int = 0
        self.notes = self.respository.read()
        
        browser?.reloadData()
        browser?.selectRowIndexes(NSIndexSet(index: index) as IndexSet, byExtendingSelection: false)
        browser?.scrollRowToVisible(index)
        self.activeNote = self.notes?[index]
    }
    
    @IBAction func createNoteButton(_ sender: NSButton) {
        let newNote = NoteModel(
            title: "An Awesome Note",
            body: "Let's write about all the great things in the world!\n\n • Pizza!\n • Coffee\n • The rest of the pizza"
        )
        
        self.respository.save(note: newNote)
        self.refresh()
        editor?.showNote(note: newNote)
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
        cell?.created.stringValue = item.created;
        
        return cell
    }
}
