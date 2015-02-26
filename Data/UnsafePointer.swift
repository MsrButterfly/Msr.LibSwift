import Foundation

extension UnsafePointer {
    static func msr_to<U>(inout value: U) -> UnsafePointer<T> {
        return UnsafePointer<T>(withUnsafePointer(&value, { $0 }))
    }
}
