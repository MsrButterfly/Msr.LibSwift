import Foundation

extension Array {
    var firstIndex: Array<T>.IndexType! {
        get {
            return count > 0 ? 0 : nil
        }
    }
    var firstOne: T! {
        get {
            return firstIndex ? self[firstIndex] : nil
        }
    }
    var lastIndex: Array<T>.IndexType! {
        get {
            return count > 0 ? endIndex - 1 : nil
        }
    }
    var lastOne: T! {
        get {
            return lastIndex ? self[lastIndex] : nil
        }
    }
}
