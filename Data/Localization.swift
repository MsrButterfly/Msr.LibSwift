import Foundation

extension Msr.Data {
    class LocalizedStrings {
        let module: NSString
        let bundle: NSBundle
        init(module: NSString, bundle: NSBundle) {
            self.module = module
            self.bundle = bundle
        }
        subscript(key: String) -> String {
            return NSLocalizedString(key, tableName: module, bundle: bundle, comment: "")
        }
    }
}

