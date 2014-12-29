extension Msr.Data {
    static func IntegerValueOfObject(object: AnyObject) -> Int {
        return ("\(object)" as NSString).integerValue
    }
    static func FloatValueOfObject(object: AnyObject) -> Float {
        return ("\(object)" as NSString).floatValue
    }
    static func DoubleValueOfObject(object: AnyObject) -> Double {
        return ("\(object)" as NSString).doubleValue
    }
    static func IntValueOfObject(object: AnyObject) -> Int32 {
        return ("\(object)" as NSString).intValue
    }
    static func LongLongValueOfObject(object: AnyObject) -> Int64 {
        return ("\(object)" as NSString).longLongValue
    }
    static func BoolValueOfObject(object: AnyObject) -> Bool {
        return ("\(object)" as NSString).boolValue
    }
}
