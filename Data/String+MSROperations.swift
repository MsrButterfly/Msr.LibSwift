import Foundation

extension String {
    func msr_stringByRemovingCharactersInSet(set: NSCharacterSet) -> String {
        return (componentsSeparatedByCharactersInSet(set) as NSArray).componentsJoinedByString("")
    }
}
