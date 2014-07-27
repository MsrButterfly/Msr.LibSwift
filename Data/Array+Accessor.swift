import Foundation

extension Array {
    var firstOne: T {
        return self[startIndex]
    }
}

extension Array {
    var lastOne: T {
        return self[endIndex - 1]
    }
}
