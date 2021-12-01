//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

public struct TransferPayload {
    let rootEntropy32: Data32?
    let bip39_32: Data32?
    let txOutPublicKey: RistrettoPublic
    public let memo: String?

    init(rootEntropy: Data32, txOutPublicKey: RistrettoPublic, memo: String? = nil) {
        self.rootEntropy32 = rootEntropy
        self.bip39_32 = nil
        self.txOutPublicKey = txOutPublicKey
        self.memo = memo?.isEmpty == false ? memo : nil
    }
    
    init(bip39: Data32, txOutPublicKey: RistrettoPublic, memo: String? = nil) {
        self.bip39_32 = bip39
        self.rootEntropy32 = nil
        self.txOutPublicKey = txOutPublicKey
        self.memo = memo?.isEmpty == false ? memo : nil
    }

    public var rootEntropy: Data {
        guard let rootEntropy = rootEntropy32 else {
            logger.error("rootEntropy not availabe in TransferPayload")
            return Data()
        }
        return rootEntropy.data
    }
    
    public var bip39: Data {
        guard let bip39 = bip39_32 else {
            logger.error("bip39 not availabe in TransferPayload")
            return Data()
        }
        return bip39.data
    }
}

extension TransferPayload: Equatable {}
extension TransferPayload: Hashable {}

extension TransferPayload {
    init?(_ transferPayload: Printable_TransferPayload) {
        guard let txOutPublicKey = RistrettoPublic(transferPayload.txOutPublicKey.data) else {
            return nil
        }
        
        let rootEntropy = Data32(transferPayload.rootEntropy)
        let bip39 = Data32(transferPayload.bip39Entropy)
        switch (bip39, rootEntropy) {
        case let (.some(bip39_32), _) where bip39_32 != Data32():
            self.bip39_32 = bip39_32
            self.rootEntropy32 = nil
        case let (_, .some(rootEntropy_32)) where rootEntropy_32 != Data32():
            self.rootEntropy32 = rootEntropy_32
            self.bip39_32 = nil
        default:
            return nil
        }
        
        self.txOutPublicKey = txOutPublicKey
        self.memo = !transferPayload.memo.isEmpty ? transferPayload.memo : nil
    }
}

extension Printable_TransferPayload {
    init(_ transferPayload: TransferPayload) {
        self.init()
        self.rootEntropy = transferPayload.rootEntropy
        self.bip39Entropy = transferPayload.bip39
        self.txOutPublicKey = External_CompressedRistretto(transferPayload.txOutPublicKey)
        if let memo = transferPayload.memo {
            self.memo = memo
        }
    }
}
