//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin

class PublicAddressTests: XCTestCase {
    func testRootEntropy() throws {
        let rootEntropyHex = "a801af55a4f6b35f0dbb4a9c754ae62b926d25dd6ed954f6e697c562a1641c21"
        let rootEntropy = Data(hexEncoded: rootEntropyHex)!
        let fogUrl = "fog://fog.alpha.development.mobilecoin.com"
        let fogAuthoritySpkiB64Encoded = """
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyFOockvCEc9TcO1NvsiUfFVzvtDsR64UIRRU\
            l3tBM2Bh8KBA932/Up86RtgJVnbslxuUCrTJZCV4dgd5hAo/mzuJOy9lAGxUTpwWWG0zZJdpt8HJRVLX\
            76CBpWrWEt7JMoEmduvsCR8q7WkSNgT0iIoSXgT/hfWnJ8KGZkN4WBzzTH7hPrAcxPrzMI7TwHqUFfmO\
            X7/gc+bDV5ZyRORrpuu+OR2BVObkocgFJLGmcz7KRuN7/dYtdYFpiKearGvbYqBrEjeo/15chI0Bu/9o\
            QkjPBtkvMBYjyJPrD7oPP67i0ZfqV6xCj4nWwAD3bVjVqsw9cCBHgaykW8ArFFa0VCMdLy7UymYU5SQs\
            fXrw/mHpr27Pp2Z0/7wpuFgJHL+0ARU48OiUzkXSHX+sBLov9X6f9tsh4q/ZRorXhcJi7FnUoagBxewv\
            lfwQfcnLX3hp1wqoRFC4w1DC+ki93vIHUqHkNnayRsf1n48fSu5DwaFfNvejap7HCDIOpCCJmRVR8mVu\
            xi6jgjOUa4Vhb/GCzxfNIn5ZYym1RuoE0TsFO+TPMzjed3tQvG7KemGFz3pQIryb43SbG7Q+EOzIigxY\
            DytzcxOO5Jx7r9i+amQEiIcjBICwyFoEUlVJTgSpqBZGNpznoQ4I2m+uJzM+wMFsinTZN3mp4FU5UHjQ\
            sHKG+ZMCAwEAAQ==
            """
        
        let fogAuthoritySpki = Data(base64Encoded: fogAuthoritySpkiB64Encoded)!

        let key = try! AccountKey.make(
            rootEntropy: rootEntropy,
            fogReportUrl: fogUrl,
            fogReportId: "",
            fogAuthoritySpki: fogAuthoritySpki).get()
        
        let publicAddress = key.publicAddress

        let expected = """
        GY1Jp3uPHD6BeUWbcfbeTuiEistjqbxCaPrGqPLeacCHPgC3uoPDFeGstnoCMwcAHNyWg5cw\
        cmfFioR4xGTRHLdJ2HhTmK6935pCBCSBBARmCKiQvYDWvJDm6Z3iwpuvQ55RqtJfA5kACMRN\
        u6w8PfGsCxfYodQ9Ps5YFGu6mVWaXDXhutN4bf93xJ3vtLhWuozLwAWiKkzgundqBPk12t8Q\
        LyAdr2C2njVBFXm7m8cmTYaJUCbLFAqcarugd4gzgi
        """
        
        XCTAssertEqual(Base58Coder.encode(publicAddress), expected)
    }
}
