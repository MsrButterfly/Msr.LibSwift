extension String {
    func msr_stringByConvertingFromEncoding(source: NSStringEncoding, toEncoding destination: NSStringEncoding) -> String? {
        let cString = cStringUsingEncoding(source)
        if cString == nil {
            return nil
        }
        return NSString(CString: cString!, encoding: destination) as? String
    }
}
