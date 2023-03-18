//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//
@testable import MobileCoin
import XCTest

#if swift(>=5.5)

@available(iOS 15.0, *)

public struct TestAccountFactory {

    enum TestAccountFactoryError: Error {
        case unknownError(_ description: String)
    }

    let fogReportUrl: String
    let fogReportId: String = ""
    let fogAuthoritySpki: Data
    let accountIndex: UInt32 = 0

    public struct TestAccountConfig {
        let name: String
        let txData: [TokenId: [UInt64]]
    }

    public struct TestAccount {
        let name: String
        let accountKey: AccountKey
    }

    func makeAccounts(
        sourceClient: MobileCoinClient,
        testAccountConfigs: [TestAccountConfig]
    ) async throws -> [TestAccount] {

        var testAccounts = [TestAccount]()
        for config in testAccountConfigs {
            let acct = try await self.createNewFundedAccount(
                sourceClient: sourceClient,
                testAccountConfig: config)
            testAccounts.append(acct)
        }

        return testAccounts
    }

    func createNewFundedAccount(
        sourceClient: MobileCoinClient,
        testAccountConfig: TestAccountConfig
    ) async throws -> TestAccount {
        guard let entropy32 = Data32(.secRngGenBytes(32)) else {
            fatalError(".secRngGenBytes(32) should always create a valid Data32")
        }

        print("New Account: \(entropy32.base64EncodedString())")

//        let entropyString = "QzNxpAlpc3yCU5qpe92TqhUHCMt0hTDwXplwu//JPiI="
//
//        guard let entropyData = Data(base64Encoded: entropyString, options: []) else {
//            throw TestAccountFactoryError.unknownError("Unable to create acct from entropy")
//        }
//
//        guard let entropy32 = Data32(entropyData) else {
//            throw TestAccountFactoryError.unknownError("Unable to create entropy32 from entropy")
//        }

        let acctKey = try AccountKey.make(
            rootEntropy: entropy32.data,
            fogReportUrl: self.fogReportUrl,
            fogReportId: self.fogReportId,
            fogAuthoritySpki: self.fogAuthoritySpki)
            .get()

        for token in testAccountConfig.txData.keys {
            guard let amounts = testAccountConfig.txData[token] else {
                throw TestAccountFactoryError.unknownError("no amounts provided")
            }

            for amount in amounts {
                let tokenAmt = Amount(amount, in: token)
                let fee = try await sourceClient.estimateTotalFee(
                    toSendAmount: tokenAmt,
                    feeLevel: .minimum)

                let transaction = try await sourceClient.prepareTransaction(
                    to: acctKey.publicAddress,
                    amount: Amount(amount, in: token),
                    fee: fee)

                try await sourceClient.submitTransaction(
                    transaction: transaction.transaction)

                var txComplete = false
                while !txComplete {
                    try await sourceClient.updateBalances()
                    let txStatus = try await sourceClient.status(of: transaction.transaction)
                    switch txStatus {
                    case .accepted(block: _ ):
                        txComplete = true
                    case .failed:
                        throw TestAccountFactoryError.unknownError("fund tx failed")
                    case .unknown:
                        // throttle the polling a bit
                        sleep(1)
                    }
                }
            }
        }

        return TestAccount(name: testAccountConfig.name, accountKey: acctKey)
    }

}

#endif
