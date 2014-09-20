import Foundation

extension Msr.Data {
    static func PrintTypeTree(object: AnyObject, layer: Int = 0) -> Void {
        var indentationString = ""
        for _ in 0...layer {
            indentationString += "   "
        }
        println("[" + String.fromCString(object_getClassName(object))! + "]")
        if let data = object as? NSDictionary {
            for (key, value) in data {
                print(indentationString + "\(key) ")
                PrintTypeTree(value, layer: layer + 1)
            }
        } else if let data = object as? NSArray {
            for value in data {
                print(indentationString)
                PrintTypeTree(value, layer: layer + 1)
            }
        }
    }
}
