//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable unused_setter_value
import Foundation

public class MobileCoinSeedableRng: MobileCoinRng {
    let _seed: Data32

    var seed: Data32 {
        _seed
    }

    init(seed: Data32) {
        self._seed = seed
    }

    override convenience init() {
        let bytesCount = 32
        var randomBytes = [UInt8](repeating: 0, count: bytesCount)

        let status = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
        guard status == errSecSuccess else {
            var message = ""
            if #available(iOS 11.3, *), let errorMessage = SecCopyErrorMessageString(status, nil) {
                message = ", message: \(errorMessage)"
            }

            logger.fatalError("Failed to generate bytes. SecError: \(status)" + message)
        }

        guard let seedData32 = Data32(Data(randomBytes)) else {
            // will not happen
            logger.fatalError("Failed to generate Data32 for rng seed.")
        }

        self.init(seed: seedData32)
    }

    var wordPos: Data16 {
        get {
            fatalError("Subclass must override wordPos getter")
        }

        set(wordpos) {
            fatalError("Subclass must override wordPos setter")
        }
    }
}
