extension Int {
    init(msr_object: AnyObject) {
        self.init(NSString(string: "\(msr_object)").integerValue)
    }
}

extension Int32 {
    init(msr_object: AnyObject) {
        self.init(NSString(string: "\(msr_object)").intValue)
    }
}

extension Int64 {
    init(msr_object: AnyObject) {
        self.init(NSString(string: "\(msr_object)").longLongValue)
    }
}

extension Float {
    init(msr_object: AnyObject) {
        self.init(NSString(string: "\(msr_object)").floatValue)
    }
}

extension Double {
    init(msr_object: AnyObject) {
        self.init(NSString(string: "\(msr_object)").doubleValue)
    }
}

extension Bool {
    init(msr_object: AnyObject) {
        self.init(NSString(string: "\(msr_object)").boolValue)
    }
}
