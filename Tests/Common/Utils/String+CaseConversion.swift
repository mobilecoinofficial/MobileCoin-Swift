//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// Derived from
// https://gist.github.com/dmsl1805/ad9a14b127d0409cf9621dc13d237457#gistcomment-3013022

import Foundation

extension String {

    func camelCaseToSnakeCase() -> String {
        let processed = processCamalCase(regex: Self.acronymRegex)?
            .processCamalCase(regex: Self.normalRegex)?
            .lowercased()
        return processed ?? lowercased()
    }

}

extension String {

    fileprivate static let acronymRegex = regex(pattern: "([A-Z]+)([A-Z][a-z]|[0-9])")
    fileprivate static let normalRegex = regex(pattern: "([a-z0-9])([A-Z])")

    fileprivate static func regex(pattern: String) -> NSRegularExpression? {
        try? NSRegularExpression(pattern: pattern, options: [])
    }

    fileprivate func processCamalCase(regex: NSRegularExpression?) -> String? {
        regex?.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: count),
            withTemplate: "$1_$2")
    }

}
