extension UIView {
    @objc func msr_resignFirstResponderOfAllSubviews() -> Void {
        for subview in subviews {
            if let textView = subview as? UITextView {
                textView.resignFirstResponder()
            } else if let textField = subview as? UITextField {
                textField.resignFirstResponder()
            }
            (subview as! UIView).msr_resignFirstResponderOfAllSubviews()
        }
    }
}
