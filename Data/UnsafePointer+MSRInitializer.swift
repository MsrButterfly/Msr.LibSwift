extension UnsafePointer {
    init<U>(inout msr_memory: U) {
        self.init(withUnsafePointer(&msr_memory, { $0 }))
    }
}
