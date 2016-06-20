import Foundation
import CommonCrypto

extension String {
    
    var msr_MD5EncryptedString: String {
        let cStr = (self as NSString).UTF8String
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
    
    var msr_SHA1EncryptedString: String {
        let cStr = (self as NSString).UTF8String
        let length = Int(CC_SHA1_DIGEST_LENGTH)
        let buffer = UnsafeMutablePointer<CUnsignedChar>.alloc(length)
        CC_SHA1(cStr, CC_LONG(strlen(cStr)), buffer)
        var result = ""
        for i in 0..<length {
            result += NSString(format: "%02x", buffer.advancedBy(i).memory) as String
        }
        return result
    }
    
}
