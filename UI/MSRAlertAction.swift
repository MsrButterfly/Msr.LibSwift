@objc class MSRAlertAction {
    var title: String
    var style: UIAlertActionStyle
    var handler: ((MSRAlertAction) -> Void)?
    var enabled: Bool
    init(title: String, style: UIAlertActionStyle, handler: ((MSRAlertAction) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
        enabled = true
    }
}
