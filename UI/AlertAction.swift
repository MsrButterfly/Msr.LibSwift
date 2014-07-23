import UIKit

extension Msr.UI {
    enum AlertActionStyle {
        case Default
        case Cancel
        case Destructive
    }
    class AlertAction {
        var title: String
        var style: AlertActionStyle
        var handler: ((AlertAction) -> Void)?
        var enabled: Bool
        init(title: String, style: AlertActionStyle, handler: ((AlertAction) -> Void)?) {
            self.title = title
            self.style = style
            self.handler = handler
            enabled = true
        }
    }
}
