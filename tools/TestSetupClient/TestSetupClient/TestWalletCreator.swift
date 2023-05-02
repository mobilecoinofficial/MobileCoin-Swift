//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//

import Foundation
import MobileCoin

enum TestWalletCreationError: Error, Equatable {
    case error(String)
}

class TestWalletCreator: ObservableObject {
    init() {
    }
    
    final func createAccounts(srcAcctEntropyString: String, testAccountSeed: String) async -> Result<Void, TestWalletCreationError> {
        do {
            let minFee: UInt64 = 400_000_000
            let minMOBUSDFee: UInt64 = 2650

            guard let fogAuthoritySpki = Data(base64Encoded: NetworkPresets.fogAuthoritySpkiB64Encoded) else {
                return .failure(.error("Unable to get fogAuthoritySpki"))
            }
            
            guard let srcAcctEntropyData = Data(base64Encoded: srcAcctEntropyString, options: []) else {
                return .failure(.error("Unable to extract entropy data from entropy string"))
            }
            
            guard let accountKey = try? AccountKey.make(
                rootEntropy: srcAcctEntropyData,
                fogReportUrl: NetworkPresets.fogUrl,
                fogReportId: "",
                fogAuthoritySpki: fogAuthoritySpki).get() else {
                return .failure(.error("Unable to create source accountKey with entropy data"))
            }

            guard let config = try? MobileCoinClient.Config.make(
                consensusUrl: "mc://node1.test.mobilecoin.com",
                consensusAttestation: NetworkPresets.consensusAttestation(),
                fogUrl: NetworkPresets.fogUrl,
                fogViewAttestation: NetworkPresets.fogViewAttestation(),
                fogKeyImageAttestation: NetworkPresets.fogLedgerAttestation(),
                fogMerkleProofAttestation: NetworkPresets.fogLedgerAttestation(),
                fogReportAttestation: NetworkPresets.fogReportAttestation(),
                transportProtocol: .grpc).get() else {
                return .failure(.error("Unable to get config"))
            }
            
            guard let sourceClient = try? MobileCoinClient.make(
                accountKey: accountKey, config: config).get() else {
                return .failure(.error("Unable to create source client"))
            }
            
            let balances = try await sourceClient.updateBalances()
            print("balances: \(balances)")
            
            let accountFactory = TestAccountFactory(
                fogReportUrl:  NetworkPresets.fogUrl,
                fogAuthoritySpki: fogAuthoritySpki)
            let testAccountConfigs = [

                // testTransactionDoubleSubmissionFails
                TestAccountFactory.TestAccountConfig(
                    name:"0_HTTP_testTransactionDoubleSubmissionFails_Client",
                    txData:
                        [.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"1_HTTP_testTransactionDoubleSubmissionFails_Recipient",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"2_GRPC_testTransactionDoubleSubmissionFails_Client",
                    txData:
                        [.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"3_GRPC_testTransactionDoubleSubmissionFails_Recipient",
                    txData:[:]),

                // testTransactionStatusFailsWhenInputsAlreadySpent
                TestAccountFactory.TestAccountConfig(
                    name:"4_HTTP_testTransactionStatusFailsWhenInputsAlreadySpent_Client",
                    txData:
                        [.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"5_HTTP_testTransactionStatusFailsWhenInputsAlreadySpent_Recipient",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"6_testTransactionStatusFailsWhenInputsAlreadySpent_Client",
                    txData:
                        [.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"7_testTransactionStatusFailsWhenInputsAlreadySpent_Recipient",
                    txData:[:]),

                // testSubmitTransaction
                TestAccountFactory.TestAccountConfig(
                    name:"8_HTTP_testSubmitTransaction_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"9_HTTP_testSubmitTransaction_Recipient",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"10_GRPC_testSubmitTransaction_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"11_GRPC_testSubmitTransaction_Recipient",
                    txData:[:]),

                // testSubmitMobUSDTransaction
                TestAccountFactory.TestAccountConfig(
                    name:"12_HTTP_testSubmitMobUSDTransaction_Client",
                    txData:[.MOBUSD : [100 + minMOBUSDFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"13_HTTP_testSubmitMobUSDTransaction_Recipient",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"14_GRPC_testSubmitMobUSDTransaction_Client",
                    txData:[.MOBUSD : [100 + minMOBUSDFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"15_GRPC_testSubmitMobUSDTransaction_Recipient",
                    txData:[:]),

                // testCancelSignedContingentInput
                TestAccountFactory.TestAccountConfig(
                    name:"16_HTTP_testCancelSignedContingentInput_Creator",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"17_HTTP_testCancelSignedContingentInput_Consumer",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"18_GRPC_testCancelSignedContingentInput_Creator",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"19_GRPC_testCancelSignedContingentInput_Consumer",
                    txData:[:]),

                // testSubmitSignedContingentInput
                TestAccountFactory.TestAccountConfig(
                    name:"20_HTTP_testSubmitSignedContingentInput_Creator",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"21_HTTP_testSubmitSignedContingentInput_Consumer",
                    txData:[
                        .MOB : [minFee],
                        .MOBUSD : [10]
                    ]),
                TestAccountFactory.TestAccountConfig(
                    name:"22_GRPC_testSubmitSignedContingentInput_Creator",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"23_GRPC_testSubmitSignedContingentInput_Consumer",
                    txData:[
                        .MOB : [minFee],
                        .MOBUSD : [10]
                    ]),

                // testSelfPaymentBalanceChange
                TestAccountFactory.TestAccountConfig(
                    name:"24_HTTP_testSelfPaymentBalanceChange_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"25_GRPC_testSelfPaymentBalanceChange_Client",
                    txData:[.MOB : [100 + minFee]]),

                // testSelfPaymentBalanceChangeFeeLevel
                TestAccountFactory.TestAccountConfig(
                    name:"26_HTTP_testSelfPaymentBalanceChangeFeeLevel_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"27_GRPC_testSelfPaymentBalanceChangeFeeLevel_Client",
                    txData:[.MOB : [100 + minFee]]),

                // testTransactionStatus
                TestAccountFactory.TestAccountConfig(
                    name:"28_HTTP_testTransactionStatus_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"29_HTTP_testTransactionStatus_Recipient",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"30_GRPC_testTransactionStatus_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"31_GRPC_testTransactionStatus_Recipient",
                    txData:[:]),

                // testTransactionTxOutStatus
                TestAccountFactory.TestAccountConfig(
                    name:"32_HTTP_testTransactionTxOutStatus_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"33_HTTP_testTransactionTxOutStatus_Recipient",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"34_GRPC_testTransactionTxOutStatus_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"35_GRPC_testTransactionTxOutStatus_Recipient",
                    txData:[:]),

                // testReceiptStatus
                TestAccountFactory.TestAccountConfig(
                    name:"36_HTTP_testReceiptStatus_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"37_HTTP_testReceiptStatus_Recipient",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"38_GRPC_testReceiptStatus_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"39_GRPC_testReceiptStatus_Recipient",
                    txData:[:]),

                // testConsensusTrustRootWorks
                TestAccountFactory.TestAccountConfig(
                    name:"40_HTTP_testConsensusTrustRootWorks_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"41_HTTP_testConsensusTrustRootWorks_Recipient",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"42_GRPC_testConsensusTrustRootWorks_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"43_GRPC_testConsensusTrustRootWorks_Recipient",
                    txData:[:]),

                // testExtraConsensusTrustRootWorks
                TestAccountFactory.TestAccountConfig(
                    name:"44_HTTP_testExtraConsensusTrustRootWorks_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"45_HTTP_testExtraConsensusTrustRootWorks_Recipient",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"46_GRPC_testExtraConsensusTrustRootWorks_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"47_GRPC_testConsensusTrustRootWorks_Recipient",
                    txData:[:]),

                // testWrongConsensusTrustRootReturnsError
                TestAccountFactory.TestAccountConfig(
                    name:"48_HTTP_testWrongConsensusTrustRootReturnsError_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"49_HTTP_testWrongConsensusTrustRootReturnsError_Recipient",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"50_GRPC_testWrongConsensusTrustRootReturnsError_Client",
                    txData:[.MOB : [100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"51_GRPC_testWrongConsensusTrustRootReturnsError_Recipient",
                    txData:[:]),

                // testIdempotenceDoubleSubmissionFailure
                TestAccountFactory.TestAccountConfig(
                    name:"52_HTTP_testIdempotenceDoubleSubmissionFailure_Client",
                    txData:[.MOB : [100 + minFee, 100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"53_HTTP_testIdempotenceDoubleSubmissionFailure_Recipient",
                    txData:[:]),
                TestAccountFactory.TestAccountConfig(
                    name:"54_GRPC_testIdempotenceDoubleSubmissionFailure_Client",
                    txData:[.MOB : [100 + minFee, 100 + minFee]]),
                TestAccountFactory.TestAccountConfig(
                    name:"55_GRPC_testIdempotenceDoubleSubmissionFailure_Recipient",
                    txData:[:]),

            ]


            let testAccounts = try await accountFactory.makeAccounts(
                sourceClient: sourceClient,
                testAccountConfigs: testAccountConfigs,
                testAccountSeed: testAccountSeed
            )

            print("Test accounts: \(testAccounts) ")
            
        } catch {
            print("Failed to create test accounts, error: \(error)")
            return .failure(.error(error.localizedDescription))
        }
        
        return .success(())
    }
}
