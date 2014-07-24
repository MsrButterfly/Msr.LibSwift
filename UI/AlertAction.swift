import UIKit

extension Msr.UI {
    class AlertAction {
        enum Style {
            case Default
            case Cancel
            case Destructive
        }
        var title: String
        var style: Style
        var handler: ((AlertAction) -> Void)?
        var enabled: Bool
        init(title: String, style: Style, handler: ((AlertAction) -> Void)?) {
            self.title = title
            self.style = style
            self.handler = handler
            enabled = true
        }
    }
}
