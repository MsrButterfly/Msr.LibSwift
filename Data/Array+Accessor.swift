import Foundation

extension Array {
    mutating func removeFirst() -> T {
        return removeAtIndex(startIndex)
    }
}
