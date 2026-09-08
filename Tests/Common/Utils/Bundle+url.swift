//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

extension Bundle {
    public static let mobilecoin_TestDataBundleIdentifier = Bundle.module.bundleIdentifier!

    public static func testDataModuleUrl(
        _ resource: String,
        withExtension ext: String
    ) throws -> URL {
        guard
            let url = Bundle.module.url(
                forResource: resource,
                withExtension: ext,
                subdirectory: "Transaction"
            )
        else {
            throw TestingError("Failed to get url for resource: \(resource).\(ext)")
        }
        return url
    }
}
