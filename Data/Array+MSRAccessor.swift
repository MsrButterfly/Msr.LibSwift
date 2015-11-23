extension Array {
    mutating func msr_removeFirst() -> Element {
        return removeAtIndex(startIndex)
    }
    var msr_second: Element? {
        return count > 1 ? self[1] : nil
    }
    var msr_penultimate: Element? {
        return count > 1 ? self[endIndex - 2] : nil
    }
}
