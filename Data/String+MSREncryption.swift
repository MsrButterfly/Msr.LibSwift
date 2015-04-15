import Foundation
import CommonCrypto

extension String {
    var msr_MD5EncryptedString: String {
        let cStr = NSString(string: self).UTF8String
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let buffer = UnsafeMutablePointer<CUnsignedChar>.alloc(length)
        CC_MD5(cStr, CC_LONG(strlen(cStr)), buffer)
        var result = ""
        for i in 0..<length {
            result += NSString(format: "%02X", buffer.advancedBy(i).memory) as String
        }
        free(buffer)
        return result
    }
}
