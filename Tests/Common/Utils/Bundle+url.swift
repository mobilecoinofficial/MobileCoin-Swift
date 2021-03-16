//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

extension Bundle {
    static func url(_ resource: String, _ ext: String) throws -> URL {
        guard let url = Bundle(for: BundleType.self).url(forResource: resource, withExtension: ext)
        else {
            throw TestingError("Failed to get url for resource: \(resource).\(ext)")
        }
        return url
    }

    private final class BundleType {}
}
