import UIKit

extension Msr.UI {
    class AlertView: UIScrollView, UITextFieldDelegate {
        private let _contentView: UIView
        let contentView: UIView
        let backgroundView: UIView
        var cornerRadius: CGFloat
        private(set) var actions: [AlertAction]
        private(set) var buttons: [UIButton]
        override init() {
            _contentView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 270, height: 0)))
            contentView = UIView(frame: _contentView.bounds)
            backgroundView = UIScrollView(frame: UIScreen.mainScreen().bounds)
            backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            actions = []
            buttons = []
            cornerRadius = 0
            super.init(frame: UIScreen.mainScreen().bounds)
            alwaysBounceVertical = true
            _contentView.center = center
            addSubview(backgroundView)
            insertSubview(_contentView, aboveSubview: backgroundView)
            _contentView.addSubview(contentView)
            alpha = 0
        }
        required convenience init(coder aDecoder: NSCoder) {
            self.init()
        }
        convenience init(title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: String?, [String]?) {
            self.init()
        }
        func show() {
            alpha = 0
            _contentView.transform = CGAffineTransformMakeScale(0.5, 0.5)
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: .BeginFromCurrentState,
                animations: {
                    [weak self] in
                    self!.alpha = 1
                    self!._contentView.transform = CGAffineTransformMakeScale(1, 1)
                },
                completion: nil)
        }
        func hide() {
            resignFirstResponderOfAllSubviews()
            alpha = 1
            _contentView.transform = CGAffineTransformMakeScale(1, 1)
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: .BeginFromCurrentState,
                animations: {
                    [weak self] in
                    self!.alpha = 0
                    self!._contentView.transform = CGAffineTransformMakeScale(0.5, 0.5)
                },
                completion: nil)
        }
        func addAction(action: AlertAction) {
            actions.append(action)
            let button = UIButton(frame: CGRectZero)
            let textColorOfStyle: (AlertAction.Style) -> UIColor = {
                style in
                switch style {
                case .Cancel:
                    return UIColor.darkTextColor()
                case .Default:
                    return UIColor.whiteColor()
                case .Destructive:
                    return UIColor.whiteColor()
                default:
                    return UIColor.clearColor()
                }
            }
            button.setTitle(action.title, forState: .Normal)
            button.setAttributedTitle(NSAttributedString(
                string: action.title,
                attributes: [
                    NSFontAttributeName: UIFont.systemFontOfSize(16),
                    NSForegroundColorAttributeName: textColorOfStyle(action.style)
                ]),
                forState: .Normal)
            button.addTarget(self, action: "handleButtonActions:", forControlEvents: .TouchUpInside)
            buttons.append(button)
            _contentView.addSubview(buttons[buttons.endIndex - 1])
        }
        override func layoutSubviews() {
            let width = _contentView.bounds.width / CGFloat(buttons.count)
            let height = 43 as CGFloat
            let radius = cornerRadius
            for (i, button) in enumerate(buttons) {
                button.frame = CGRect(x: width * CGFloat(i), y: contentView.bounds.height, width: width, height: height)
            }
            _contentView.bounds = CGRect(origin: CGPointZero, size: CGSize(width: contentView.bounds.width, height: contentView.bounds.height + height))
            _contentView.center = center
            contentView.frame = contentView.bounds
            let defaultColor = backgroundColor!.colorWithAlphaComponent(0.9)
            contentView.backgroundColor = UIColor(
                patternImage: UIImage.msr_roundedRectangleWithColor(backgroundColor!, size: contentView.bounds.size, cornerRadius: (radius, radius, 0, 0)))
            let backgroundColorOfStyle = {
                (style: AlertAction.Style) -> UIColor in
                switch style {
                case .Cancel:
                    return UIColor.whiteColor().colorWithAlphaComponent(0.9)
                case .Default:
                    return defaultColor
                case .Destructive:
                    return UIColor.redColor().colorWithAlphaComponent(0.9)
                default:
                    return UIColor.clearColor()
                }
            }
            switch buttons.count {
            case 0:
                break
            case 1:
                buttons[0].setBackgroundImage(
                    UIImage.msr_roundedRectangleWithColor(backgroundColorOfStyle(actions[0].style),
                        size: buttons[0].bounds.size,
                        cornerRadius: (0, 0, radius, radius)),
                    forState: .Normal)
                break
            default:
                buttons[0].setBackgroundImage(
                    UIImage.msr_roundedRectangleWithColor(backgroundColorOfStyle(actions[0].style),
                        size: buttons[0].bounds.size,
                        cornerRadius: (0, 0, 0, radius)),
                    forState: .Normal)
                buttons[buttons.endIndex - 1].setBackgroundImage(
                    UIImage.msr_roundedRectangleWithColor(backgroundColorOfStyle(actions[buttons.endIndex - 1].style),
                        size: buttons[0].bounds.size,
                        cornerRadius: (0, 0, radius, 0)),
                    forState: .Normal)
                for (i, button) in enumerate(buttons[1..<buttons.count - 1]) {
                    button.setBackgroundImage(
                        UIImage.msr_rectangleWithColor(backgroundColorOfStyle(actions[i + 1].style), size: button.bounds.size),
                        forState: .Normal)
                }
                break
            }
        }
        func handleButtonActions(button: UIButton?) {
            var index: Array<UIButton>.Index!
            for i in 0..<buttons.endIndex {
                if buttons[i] == button {
                    index = i
                }
            }
            assert(index != nil, "fatal error: Unexpected button action.")
            actions[index].handler?(actions[index])
            hide()
        }
    }
}

