import Cocoa

extension NSTableView {
    open override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let globalLocation = event.locationInWindow
        let localLocation = self.convert(globalLocation, to: nil)
        let selectedRow = self.row(at: localLocation)
        
        if (selectedRow != -1) {
            (self.delegate as? NSTableViewClickableDelegate)?.tableView(self, didClickRow: selectedRow)
        }
    }
}

protocol NSTableViewClickableDelegate: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, didClickRow selectedRow: Int)
}
