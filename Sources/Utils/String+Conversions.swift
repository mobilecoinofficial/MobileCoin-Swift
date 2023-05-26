//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

extension String {
    func camelCaseToWords() -> String {
        let variable = unicodeScalars.dropFirst()
        variable.reduce(String(prefix(1))) {
            CharacterSet.uppercaseLetters.contains($1)
                ? $0 + " " + String($1)
                : $0 + String($1)
        }
    }
}
