//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct DestinationMemo {
    public var memoData: Data { memoData64.data }
    public var addressHashHex: String { addressHash.hex }
    public var numberOfRecipients: UInt8 { numRecipients.value }

    let memoData64: Data64
    let addressHash: AddressHash
    let numRecipients: PositiveUInt8
    public let fee: UInt64
    public let totalOutlay: UInt64
}

extension DestinationMemo: Equatable, Hashable { }

extension DestinationMemo: Encodable {
    enum CodingKeys: String, CodingKey {
        case addressHashHex
        case numberOfRecipients
        case fee
        case totalOutlay
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(addressHashHex, forKey: .addressHashHex)
        try container.encode(numberOfRecipients, forKey: .numberOfRecipients)
        try container.encode(fee, forKey: .fee)
        try container.encode(totalOutlay, forKey: .totalOutlay)
    }
}

struct RecoverableDestinationMemo {
    let memoData: Data64
    let addressHash: AddressHash
    let txOutPublicKey: RistrettoPublic
    let txOutTargetKey: RistrettoPublic
    private let accountKey: AccountKey

    init(_ memoData: Data64, accountKey: AccountKey, txOutKeys: TxOut.Keys) {
        self.memoData = memoData
        self.addressHash = DestinationMemoUtils.getAddressHash(memoData: memoData)
        self.accountKey = accountKey
        self.txOutPublicKey = txOutKeys.publicKey
        self.txOutTargetKey = txOutKeys.targetKey
    }

    func recover() -> DestinationMemo? {
        guard
            DestinationMemoUtils.isValid(
                txOutPublicKey: txOutPublicKey,
                txOutTargetKey: txOutTargetKey,
                accountKey: accountKey),
            let numberOfRecipients = DestinationMemoUtils.getNumberOfRecipients(memoData: memoData),
            let fee = DestinationMemoUtils.getFee(memoData: memoData),
            let totalOutlay = DestinationMemoUtils.getTotalOutlay(memoData: memoData)
        else {
            logger.debug("Memo did not validate")
            return nil
        }
        let addressHash = DestinationMemoUtils.getAddressHash(memoData: memoData)
        return DestinationMemo(
            memoData64: memoData,
            addressHash: addressHash,
            numRecipients: numberOfRecipients,
            fee: fee,
            totalOutlay: totalOutlay)
    }
}

extension RecoverableDestinationMemo: Hashable { }

extension RecoverableDestinationMemo: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.memoData == rhs.memoData
    }
}
