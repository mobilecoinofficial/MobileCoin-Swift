//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_parameters_brackets

import Foundation

public protocol HttpRequester {
    func request(
        url: URL,
        method: String,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<Void, Error>) -> Void)
}
