//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class ReconstructedCommitmentTests: XCTestCase {

    func testPartialTxOutCreation() throws {
        let fixture = try Transaction.Fixtures.Commitment()
        let partialTxOut = PartialTxOut(fixture.txOutRecord, viewKey: fixture.viewKey)
        XCTAssertNotNil(partialTxOut)
    }
    
    func testReconstructCommitment() throws {
        let fixture = try Transaction.Fixtures.Commitment()
        let txOutRecord = fixture.txOutRecord
        let viewKey = fixture.viewKey
        guard let publicKey = RistrettoPublic(txOutRecord.txOutPublicKeyData),
              let commitment = TxOutUtils.reconstructCommitment(
                                                    maskedValue: txOutRecord.txOutAmountMaskedValue,
                                                    publicKey: publicKey,
                                                    viewPrivateKey: viewKey) else {
            XCTFail("Unable to reconstruct commitment")
            return
        }
        
        let isMatching = PartialTxOut.isCrc32Matching(commitment, txOutRecord: txOutRecord)
        XCTAssertTrue(isMatching, "Commitment values not matching")
    }
    
    func testCrc32() throws {
        let fixture = try Transaction.Fixtures.Commitment()
        let txOutRecord = fixture.txOutRecord
        let commitment = txOutRecord.txOutAmountCommitmentData
        let crc32: UInt32 = {
            guard let data32 = Data32(commitment) else { return nil }
            return TxOutUtils.calculateCrc32(from: data32)
        }() ?? .emptyCrc32

        XCTAssertEqual(crc32, fixture.crc32)
    }
}
