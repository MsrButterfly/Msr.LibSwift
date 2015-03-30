extension UIButton {
    func msr_setBackgroundImageWithColor(color: UIColor) {
        msr_setBackgroundImageWithColor(color, forState: .Normal)
    }
    func msr_setBackgroundImageWithColor(color: UIColor, forState state: UIControlState) {
        self.setBackgroundImage(UIImage.msr_imageWithColor(color), forState: state)
    }
}
