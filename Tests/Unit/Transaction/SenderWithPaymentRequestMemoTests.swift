//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin
@testable import LibMobileCoin

class SenderWithPaymentRequestMemoTests: XCTestCase {
    func testAliceBobCreateSenderWithPaymentRequestMemo() throws {
        let alice_bytes_hex = SenderWithPaymentRequestMemoData.Fixtures.alice_bytes
        let bob_bytes_hex = SenderWithPaymentRequestMemoData.Fixtures.bob_bytes
        let tx_out_public_key_hex = SenderWithPaymentRequestMemoData.Fixtures.tx_public_key_bytes
        
        let alice_account_key = AccountKey(serializedData: Data(hexEncoded: alice_bytes_hex)!)
        let bob_account_key = AccountKey(serializedData: Data(hexEncoded: bob_bytes_hex)!)
        let tx_out_public_key = RistrettoPublic(Data(hexEncoded: tx_out_public_key_hex)!)
        
        let paymentRequestId: UInt64 = 17014
        
        //  ccb5a98f0c0c42f68491e5e0c9362452000000000000427600000000000000000000000000000000000000000000000007c61e75690f221bf0834b22e6833820
        let senderMemoData = SenderWithPaymentRequestMemoData.create(senderAccountKey: alice_account_key!, receipientPublicAddress: bob_account_key!.publicAddress, txOutPublicKey: tx_out_public_key!, paymentRequestId: paymentRequestId)
        XCTAssertNotNil(senderMemoData)
        print("\(senderMemoData?.hexEncodedString())")
        
        let isValid = SenderWithPaymentRequestMemoData.isValid(memoData: senderMemoData!, senderPublicAddress: alice_account_key!.publicAddress, receipientViewPrivateKey: bob_account_key!.subaddressViewPrivateKey, txOutPublicKey: tx_out_public_key!)
        XCTAssertTrue(isValid)
        
        // ccb5a98f0c0c42f68491e5e0c9362452
        let createdAddressHash = alice_account_key?.publicAddress.calculateAddressHash()
        let addressHashFromMemoData = SenderWithPaymentRequestMemoData.getAddressHash(memoData: senderMemoData!)
        
        XCTAssertTrue(createdAddressHash! == addressHashFromMemoData!)
        
        let memoDataPaymentRequestId = SenderWithPaymentRequestMemoData.getPaymentRequestId(memoData: senderMemoData!)
        XCTAssertEqual(memoDataPaymentRequestId, paymentRequestId)
    }
}


struct SenderWithPaymentRequestMemoData {
    enum Fixtures {}
    
    
    static func isValid(
        memoData: Data64,
        senderPublicAddress: PublicAddress,
        receipientViewPrivateKey: RistrettoPrivate,
        txOutPublicKey: RistrettoPublic
    ) -> Bool {
        memoData.asMcBuffer { memoDataPtr in
            senderPublicAddress.withUnsafeCStructPointer { publicAddressPtr in
                receipientViewPrivateKey.asMcBuffer { receipientViewPrivateKeyPtr in
                    txOutPublicKey.asMcBuffer { txOutPublicKeyPtr in
                        var matches = true
                        // Safety: mc_tx_out_matches_any_subaddress is infallible when preconditions are
                        // upheld.
                        let result = withMcError { errorPtr in
                            mc_memo_sender_with_payment_request_memo_is_valid(
                                memoDataPtr,
                                publicAddressPtr,
                                receipientViewPrivateKeyPtr,
                                txOutPublicKeyPtr,
                                &matches,
                                &errorPtr)
                        }
                        print(matches)
                        switch result {
                        case .success():
                            return true
                        case .failure(let error):
                            print("\(error)")
                            return false
                        }
                    }
                }
            }
        }
    }
    
    static func getAddressHash(
        memoData: Data64
    ) -> AddressHash? {
        let bytes: Data16? = memoData.asMcBuffer { memoDataPtr in
            switch Data16.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                mc_memo_sender_with_payment_request_memo_get_address_hash(
                    memoDataPtr,
                    bufferPtr,
                    &errorPtr)
            }) {
            case .success(let bytes):
                // Safety: It's safe to skip validation because
                // mc_tx_out_reconstruct_commitment should always return a valid
                // RistrettoPublic on success.
                return bytes as Data16
            case .failure(let error):
                switch error.errorCode {
                case .invalidInput:
                    // Safety: This condition indicates a programming error and can only
                    // happen if arguments to mc_tx_out_reconstruct_commitment are
                    // supplied incorrectly.
                    logger.warning("error: \(redacting: error)")
                    return nil
                default:
                    // Safety: mc_tx_out_reconstruct_commitment should not throw
                    // non-documented errors.
                    logger.warning("Unhandled LibMobileCoin error: \(redacting: error)")
                    return nil
                }
            }
        }
        guard let bytes = bytes else { return nil }
        print("address hash bytes \(bytes.data.hexEncodedString())")
        return AddressHash(bytes)
    }
    
    static func create(
        senderAccountKey: AccountKey,
        receipientPublicAddress: PublicAddress,
        txOutPublicKey: RistrettoPublic,
        paymentRequestId: UInt64
    ) -> Data64? {
        senderAccountKey.withUnsafeCStructPointer { senderAccountKeyPtr in
            receipientPublicAddress.viewPublicKeyTyped.asMcBuffer { viewPublicKeyPtr in
                txOutPublicKey.asMcBuffer { txOutPublicKeyPtr in
                    switch Data64.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                        mc_memo_sender_with_payment_request_memo_create(
                            senderAccountKeyPtr,
                            viewPublicKeyPtr,
                            txOutPublicKeyPtr,
                            paymentRequestId,
                            bufferPtr,
                            &errorPtr)
                    }) {
                    case .success(let bytes):
                        // TODO - Update
                        
                        // Safety: It's safe to skip validation because
                        // mc_tx_out_reconstruct_commitment should always return a valid
                        // RistrettoPublic on success.
                        return bytes as Data64
                    case .failure(let error):
                        switch error.errorCode {
                        case .invalidInput:
                            // Safety: This condition indicates a programming error and can only
                            // happen if arguments to mc_tx_out_reconstruct_commitment are
                            // supplied incorrectly.
                            logger.warning("error: \(redacting: error)")
                            return nil
                        default:
                            // Safety: mc_tx_out_reconstruct_commitment should not throw
                            // non-documented errors.
                            logger.warning("Unhandled LibMobileCoin error: \(redacting: error)")
                            return nil
                        }
                    }
                }
            }
        }
    }
    
    
    static func getPaymentRequestId(
        memoData: Data64
    ) -> UInt64? {
        memoData.asMcBuffer { memoDataPtr in
            var out_payment_request_id: UInt64 = 0
            let result = withMcError { errorPtr in
                mc_memo_sender_with_payment_request_memo_get_payment_request_id(
                    memoDataPtr,
                    &out_payment_request_id,
                    &errorPtr)
            }
            switch (result) {
            case .success():
                // Safety: It's safe to skip validation because
                // mc_tx_out_reconstruct_commitment should always return a valid
                // RistrettoPublic on success.
                return out_payment_request_id
            case .failure(let error):
                switch error.errorCode {
                case .invalidInput:
                    // Safety: This condition indicates a programming error and can only
                    // happen if arguments to mc_tx_out_reconstruct_commitment are
                    // supplied incorrectly.
                    logger.warning("error: \(redacting: error)")
                    return nil
                default:
                    // Safety: mc_tx_out_reconstruct_commitment should not throw
                    // non-documented errors.
                    logger.warning("Unhandled LibMobileCoin error: \(redacting: error)")
                    return nil
                }
            }
        }
    }
    
}

extension SenderWithPaymentRequestMemoData.Fixtures {
      // This data was generated from the rust code.
    static let alice_bytes = "0a220a20ec8cb9814ac5c1a4aacbc613e756744679050927cc9e5f8772c6d649d4a5ac0612220a20e7ef0b2772663314ecd7ee92008613764ab5669666d95bd2621d99d60506cb0d1a1e666f673a2f2f666f672e616c7068612e6d6f62696c65636f696e2e636f6d2aa60430820222300d06092a864886f70d01010105000382020f003082020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0ec47ae14211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940ab4c9642578760779840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c94552d7efa081a56ad612dec932812676ebec091f2aed69123604f4888a125e04ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308ed3c07a9415f98e5fbfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37bfdd62d75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623c893eb0fba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781aca45bc02b1456b454231d2f2ed4ca6614e5242c7d7af0fe61e9af6ecfa76674ffbc29b858091cbfb4011538f0e894ce45d21d7fac04ba2ff57e9ff6db21e2afd9468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa84450b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a36a9ec708320ea42089991551f2656ec62ea38233946b85616ff182cf17cd227e596329b546ea04d13b053be4cf3338de777b50bc6eca7a6185cf7a5022bc9be3749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a64048887230480b0c85a045255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779a9e055395078d0b07286f9930203010001"

    static let bob_bytes = "0a220a20553a1c51c1e91d3105b17c909c163f8bc6faf93718deb06e5b9fdb9a24c2560912220a20db8b25545216d606fc3ff6da43d3281e862ba254193aff8c408f3564aefca5061a1e666f673a2f2f666f672e616c7068612e6d6f62696c65636f696e2e636f6d2aa60430820222300d06092a864886f70d01010105000382020f003082020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0ec47ae14211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940ab4c9642578760779840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c94552d7efa081a56ad612dec932812676ebec091f2aed69123604f4888a125e04ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308ed3c07a9415f98e5fbfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37bfdd62d75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623c893eb0fba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781aca45bc02b1456b454231d2f2ed4ca6614e5242c7d7af0fe61e9af6ecfa76674ffbc29b858091cbfb4011538f0e894ce45d21d7fac04ba2ff57e9ff6db21e2afd9468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa84450b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a36a9ec708320ea42089991551f2656ec62ea38233946b85616ff182cf17cd227e596329b546ea04d13b053be4cf3338de777b50bc6eca7a6185cf7a5022bc9be3749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a64048887230480b0c85a045255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779a9e055395078d0b07286f9930203010001"

    static let tx_public_key_bytes = "c235c13c4dedd808e95f428036716d52561fad7f51ce675f4d4c9c1fa1ea2165"

    static var validMemoDataHexBytes: String = "ccb5a98f0c0c42f68491e5e0c93624520000000000000000000000000000000000000000000000000000000000000000bf2eef7c5c35df8f909e40fbd118e426";
    
    static var validAddressHashHexBytes: String = "ccb5a98f0c0c42f68491e5e0c9362452"
}
