//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//
@testable import MobileCoin
import XCTest

#if swift(>=5.5)

@available(iOS 15.0, macOS 12.0, *)

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
        let txAmounts: [Amount]

        init(name: String, txAmounts: [Amount]) {
            self.name = name
            self.txAmounts = txAmounts
        }

        init(name: String, txData: [TokenId: [UInt64]]) {
            self.name = name
            var amounts = [Amount]()
            for tokenId in txData.keys {
                guard let vals = txData[tokenId] else { continue }
                for val in vals {
                    amounts.append(Amount(val, in: tokenId))
                }
            }
            self.txAmounts = amounts
        }
    }

    public struct TestAccount {
        var name: String { config.name }
        let accountKey: AccountKey
        let config: TestAccountConfig
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

        let acctKey = try AccountKey.make(
            rootEntropy: entropy32.data,
            fogReportUrl: self.fogReportUrl,
            fogReportId: self.fogReportId,
            fogAuthoritySpki: self.fogAuthoritySpki)
            .get()

        for amount in testAccountConfig.txAmounts {
            let fee = try await sourceClient.estimateTotalFee(
                toSendAmount: amount,
                feeLevel: .minimum)

            let transaction = try await sourceClient.prepareTransaction(
                to: acctKey.publicAddress,
                amount: amount,
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

        return TestAccount(accountKey: acctKey, config: testAccountConfig)
    }

}

#endif
