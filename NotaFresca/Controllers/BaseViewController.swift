
import Foundation
import Cocoa

class BaseViewController: NSViewController {
    public var i18n: I18nHelper?
    
    required init?(coder: NSCoder) {
        self.i18n = I18nHelper()
        super.init(coder: coder)
    }
}
