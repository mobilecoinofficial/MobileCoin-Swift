//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable all

import Foundation

protocol AddressHashProvider {
    var addressHash: AddressHash { get }
}

public protocol PublicAddressProvider {
    var publicAddress: PublicAddress { get }
}

extension PublicAddressProvider {
    var addressHash: AddressHash {
        self.publicAddress.calculateAddressHash()!
    }
}
