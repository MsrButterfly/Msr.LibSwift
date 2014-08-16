import UIKit

extension Msr.Data {
    class Property: Printable, DebugPrintable {
        let value: NSObject!
        init(module: NSString, bundle: NSBundle) {
            let path = bundle.pathForResource(module, ofType: "plist")
            value = NSDictionary(contentsOfFile: path)
        }
        init(value: NSObject!) {
            self.value = value
        }
        func isNull() -> Bool {
            return value is NSNull
        }
        func asColor() -> UIColor! {
            return UIColor(
                red: (value as NSDictionary)["Red"] as CGFloat / 255,
                green: (value as NSDictionary)["Green"] as CGFloat / 255,
                blue: (value as NSDictionary)["Blue"] as CGFloat / 255,
                alpha: (value as NSDictionary)["Alpha"] as CGFloat)
        }
        func asString() -> String! {
            return value as? String
        }
        func asInt() -> Int! {
            if value is Int {
                return value as? Int
            } else {
                return (value as? String)?.toInt()
            }
        }
        func asFloat() -> Float! {
            return value as? Float
        }
        func asData() -> NSData! {
            return value as? NSData
        }
        func asDate() -> NSDate! {
            return value as? NSDate
        }
        func asBool() -> Bool! {
            return value as? Bool
        }
        func asArray() -> [AnyObject]! {
            return value as? [AnyObject]
        }
        func asDictionary() -> [String: AnyObject]! {
            return value as? [String: AnyObject]
        }
        func asURL() -> NSURL! {
            return NSURL(string: asString())
        }
        subscript(key: String) -> Property! {
            return Property(value: (value as NSDictionary)[key] as? NSObject)
        }
        subscript(key: Int) -> Property! {
            return Property(value: (value as NSArray)[key] as? NSObject)
        }
        var description: String {
            return value.description!
        }
        var debugDescription: String {
            return value.debugDescription!
        }
    }
}
