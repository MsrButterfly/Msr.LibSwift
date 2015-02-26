import Foundation

extension Msr.Data {
    static func DumpTypeTree(object: AnyObject, layer: Int = 1) -> Void {
        var indentationString = ""
        for _ in 0..<layer {
            indentationString += "   "
        }
        println(String.fromCString(object_getClassName(object))!)
        if let data = object as? NSDictionary {
            for (key, value) in data {
                print(indentationString + "\(key): ")
                DumpTypeTree(value, layer: layer + 1)
            }
        } else if let data = object as? NSArray {
            println("NSArray")
            for value in data {
                print(indentationString)
                DumpTypeTree(value, layer: layer + 1)
            }
        }
    }
}
