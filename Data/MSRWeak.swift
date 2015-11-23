class MSRWeak<T: AnyObject> {
    init(object: T?) {
        self.object = object
    }
    weak var object: T?
}
