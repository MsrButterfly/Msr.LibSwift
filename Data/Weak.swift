import Foundation

// Swift has no 'namespace' without frameworks.
// Generic types cannot be nested into extensions.
@objc class MsrWeak<T: AnyObject> {
    init(object: T?) {
        self.object = object
    }
    weak var object: T?
}
