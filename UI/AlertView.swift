import UIKit

extension Msr.UI {
    class AlertView: UIView, UITextFieldDelegate {
        let contentView: UIView
        let backgroundView: UIScrollView
        var actions: [AlertAction]
        var buttons: [UIButton]
        init() {
            contentView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 270, height: 0)))
            backgroundView = UIScrollView(frame: UIScreen.mainScreen().bounds)
            backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            backgroundView.alwaysBounceVertical = true
            actions = []
            buttons = []
            super.init(frame: UIScreen.mainScreen().bounds)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap:")
            backgroundView.addGestureRecognizer(tapGestureRecognizer)
            contentView.center = center
            contentView.layer.cornerRadius = 7
            addSubview(backgroundView)
            addSubview(contentView)
            alpha = 0
        }
        convenience init(title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitles: String?, [String]?) {
            self.init()
        }
        func tap(gestureRecognizor: UITapGestureRecognizer?) {
            if let recognizor = gestureRecognizor {
                switch recognizor.state {
                case .Ended:
                    hide()
                    break
                default:
                    break
                }
            }
        }
        func show() {
            alpha = 0
            contentView.transform = CGAffineTransformMakeScale(0.5, 0.5)
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: .BeginFromCurrentState,
                animations: {
                    [weak self] in
                    self!.alpha = 1
                    self!.contentView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: nil)
        }
        func hide() {
            resignFirstResponderOfAllSubviews()
            alpha = 1
            contentView.transform = CGAffineTransformMakeScale(1, 1)
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: .BeginFromCurrentState,
                animations: {
                    [weak self] in
                    self!.alpha = 0
                    self!.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5)
                }, completion: nil)
            
            UIView.animateWithDuration(0.7) {
                
            }
        }
        func addAction(action: AlertAction) {
            actions += action
            let button = UIButton(frame: CGRectZero)
            button.titleLabel.text = action.title
            button.titleLabel.textAlignment = .Center
            button.addTarget(self, action: "handleButtonActions:", forControlEvents: .TouchUpInside)
            buttons += button
            contentView.addSubview(buttons[buttons.endIndex - 1])
        }
        override func layoutSubviews() {
            let width = contentView.bounds.width / CGFloat(buttons.count)
            let height = 43 as CGFloat
            let radius = contentView.layer.cornerRadius
            for (i, button) in enumerate(buttons) {
                button.frame = CGRect(x: width * CGFloat(i), y: contentView.bounds.height - height, width: width, height: height)
            }
            switch buttons.count {
            case 0:
                var bounds = contentView.bounds
                bounds.size.height = height
                contentView.bounds = bounds
                break
            case 1:
                var bounds = contentView.bounds
                bounds.size.height = height + 78
                contentView.bounds = bounds
                buttons[0].setBackgroundImage(
                    RoundedRectangle(
                        color: UIColor.randomColor(true),
                        size: buttons[0].bounds.size,
                        cornerRadius: (0, 0, radius, radius)).image,
                    forState: .Normal)
                break
            default:
                var bounds = contentView.bounds
                bounds.size.height = height + 78
                contentView.bounds = bounds
                buttons[0].setBackgroundImage(
                    RoundedRectangle(
                        color: UIColor.randomColor(true),
                        size: buttons[0].bounds.size,
                        cornerRadius: (0, 0, 0, radius)).image,
                    forState: .Normal)
                buttons[buttons.endIndex - 1].setBackgroundImage(
                    RoundedRectangle(
                        color: UIColor.randomColor(true),
                        size: buttons[0].bounds.size,
                        cornerRadius: (0, 0, radius, 0)).image,
                    forState: .Normal)
                for button in buttons[1..<buttons.count - 1] {
                    button.setBackgroundImage(
                        Rectangle(
                            color: UIColor.randomColor(true),
                            size: button.bounds.size).image,
                        forState: .Normal)
                }
                break
            }
            contentView.center = center
        }
        func handleButtonActions(button: UIButton?) {
            var index: Array<UIButton>.IndexType!
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

