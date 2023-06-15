//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct Data32 {
    private(set) var data: Data

    /// Initialize with a repeating byte pattern
    ///
    /// - parameter repeatedValue: A byte to initialize the pattern
    init(repeating repeatedValue: UInt8) {
        self.data = Data(repeating: repeatedValue, count: 32)
    }

    /// Initialize with zeroed bytes.
    init() {
        self.data = Data(count: 32)
    }
}

extension Data32: MutableDataImpl {
    typealias Iterator = Data.Iterator

    init?(_ data: Data) {
        guard data.count == 32 else {
            return nil
        }
        self.data = data
    }

    mutating func withUnsafeMutableBytes<ResultType>(
        _ body: (UnsafeMutableRawBufferPointer) throws -> ResultType
    ) rethrows -> ResultType {
        try data.withUnsafeMutableBytes(body)
    }

    /// Sets or returns the byte at the specified index.
    subscript(index: Int) -> UInt8 {
        get { data[index] }
        set { data[index] = newValue }
    }

    subscript(bounds: Range<Int>) -> Data {
        get { data[bounds] }
        set { data[bounds] = newValue }
    }
}
