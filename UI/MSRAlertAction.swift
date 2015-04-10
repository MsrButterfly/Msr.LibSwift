import UIKit

@objc class MSRAlertAction: NSObject {
    var title: String
    var style: UIAlertActionStyle
    var handler: ((MSRAlertAction) -> Void)?
    var enabled: Bool
    init(title: String, style: UIAlertActionStyle, handler: ((MSRAlertAction) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
        enabled = true
        super.init()
    }
}
