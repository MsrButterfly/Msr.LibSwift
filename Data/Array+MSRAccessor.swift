extension Array {
    mutating func msr_removeFirst() -> T {
        return removeAtIndex(startIndex)
    }
    var msr_second: T? {
        return count > 1 ? self[1] : nil
    }
    var msr_penultimate: T? {
        return count > 1 ? self[endIndex - 2] : nil
    }
}
