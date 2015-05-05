import Foundation

extension NSObject {
    @objc func msr_clone() -> NSObject {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self as NSObject)
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSObject
    }
}
