import Foundation

extension Array {
    mutating func removeFirst() -> T {
        return removeAtIndex(startIndex)
    }
    var second: T? {
        return count > 1 ? self[1] : nil
    }
    var penultimate: T? {
        return count > 1 ? self[endIndex - 2] : nil
    }
}
