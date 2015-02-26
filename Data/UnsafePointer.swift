import Foundation

extension UnsafePointer {
    static func msr_of(inout value: T) -> UnsafePointer<T> {
        return withUnsafePointer(&value, { $0 })
    }
}
