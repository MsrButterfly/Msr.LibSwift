import Foundation

extension Msr.Data {
    class Property: NSDictionary {
        subscript(key: String) -> Property! {
            get {
                return self.objectForKey(key) as? Property
            }
        }
    }
}