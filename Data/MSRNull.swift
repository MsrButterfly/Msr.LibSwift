import Foundation

func MSRIsNilOrNull(object: AnyObject?) -> Bool {
    return object == nil || object is NSNull
}
