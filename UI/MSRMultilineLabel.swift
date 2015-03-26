class MSRMultilineLabel: UILabel {
    override func layoutSubviews() {
        preferredMaxLayoutWidth = bounds.width
        super.layoutSubviews()
    }
}
