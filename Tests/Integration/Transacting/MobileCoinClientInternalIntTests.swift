//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable all

@testable import MobileCoin
import XCTest

class MobileCoinClientInternalIntTests: XCTestCase {

    let defrageeIndex = 5
    let defragerIndex = 6
    
    func testDefragmentationTesting() throws {
        let description = "Defragmentation Testing"
        try testSupportedProtocols(description: description, timeout: 250) {
            try defragmentationTesting(transportProtocol: $0, expectation: $1)
        }
    }
    
    func defragmentationTesting(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        func verifyBalanceChange(
            _ client: MobileCoinClient,
            _ balancesBefore: Balances,
            completion: @escaping (Result<UInt64, InvalidInputError>) -> Void
        ) {
            var numChecksRemaining = 5
            func checkBalanceChange() {
                numChecksRemaining -= 1
                print("Defrag updating balance...")
                client.updateBalances {
                    guard let balances = $0.successOrFulfill(expectation: expect) else { return }
                    print("Balances: \(balances)")
                        
                    var diff: UInt64 = 0
                    do {
                        let balancesMap = balances.balances
                        let balancesBeforeMap = balancesBefore.balances
                        let mob = balancesMap[TokenId.MOB]?.amount() ?? 0
                        let initialMob = try XCTUnwrap(balancesBeforeMap[.MOB]?.amount())
                        
                        guard mob != initialMob else {
                            guard numChecksRemaining > 0 else {
                                XCTFail("Failed to receive a changed balance. initial balance: " +
                                        "\(initialMob), current balance: " +
                                        "\(mob) picoMOB")
                                expect.fulfill()
                                return
                            }
                            
                            Thread.sleep(forTimeInterval: 2)
                            checkBalanceChange()
                            return
                        }
                        diff = 9
                    } catch {}
                    completion(.success(diff))
                }
            }
            checkBalanceChange()
        }
        
        // Figure out full spendable amount of coins in 5
        // Defragment account 5 if necc.
        // Send all coins from account 5 to
        // Fragment Accoutn by submitting 20 transactions of (full-amount/20) from 6 to 5
        // verify that account 5 needs to be defragged to send full amount ...
        //     (now in 20 txOuts, but 16 is our Transaction Max, so defrag required should be true)
        //
        // defrag account 5
        // verify that account 5 does not need to be defragged to send full-amount, success.
        let splitFactor = McConstants.MAX_INPUTS + 4
        
        let defrageeAccount = try IntegrationTestFixtures.createAccountKey(accountIndex: defrageeIndex)
        let defragerAccount = try IntegrationTestFixtures.createAccountKey(accountIndex: defragerIndex)
        
        func fragmentDefrageeAccount(
            defragee: MobileCoinClient,
            defrager: MobileCoinClient,
            amount: UInt64,
            count: Int,
            index: Int,
            completion: @escaping (Result<(), TransactionSubmissionError>) -> Void
        ) {
            guard index != count else {
                completion(.success(()))
                return
            }
            
            let fragmentAmount = amount.dividedReportingOverflow(by: UInt64(splitFactor)).partialValue
            
            print("Defrag, defragee account is being fragmented by the Defrager")
            print("Defrag transaction preperation")
            defrager.prepareTransaction(
                to: defrageeAccount.publicAddress,
                amount: fragmentAmount,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                else { return }
                
                print("Defrag transaction preperation successful")
                let defragerBalances = defrager.balances
                defrager.submitTransaction(transaction) {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }
                    
                    print("Defrag transaction submission successful")
                    
                    verifyBalanceChange(defrager, defragerBalances) { _ in
                        defrager.updateBalances() { _ in
                            fragmentDefrageeAccount(
                                defragee: defragee,
                                defrager: defrager,
                                amount: amount,
                                count: count,
                                index: (index + 1),
                                completion: completion
                            )
                        }
                    }
                }
            }
        }

        func loadUpDefragerAccount(
            defrageeClient: MobileCoinClient,
            defragerClient: MobileCoinClient,
            fullAmount: UInt64,
            completion: @escaping () -> Void
        ) {
            defrageeClient.prepareTransaction(
                to: defragerAccount.publicAddress,
                amount: fullAmount,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                else { return }
                
                let defragerBalances = defragerClient.balances
                let defrageeBalances = defrageeClient.balances
                defrageeClient.submitTransaction(transaction) {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }
                    
                    print("Defrag transaction submission successful")
                    
                    verifyBalanceChange(defragerClient, defragerBalances, completion: { _ in
                        verifyBalanceChange(defrageeClient, defrageeBalances, completion: { _ in
                            completion()
                        })
                    })
                }
            }
        }
        
        func createBothClients(
            completion: @escaping (_ defragee: MobileCoinClient, _ defrager: MobileCoinClient) -> Void
        ) {
            do {
                try IntegrationTestFixtures.createMobileCoinClientWithBalance(
                    accountIndex: defragerIndex,
                    expectation: expect,
                    transportProtocol: transportProtocol)
                { defragerClient in
                    try? IntegrationTestFixtures.createMobileCoinClientWithBalance(
                        accountIndex: self.defrageeIndex,
                        expectation: expect,
                        transportProtocol: transportProtocol)
                    { defrageeClient in
                        completion(defrageeClient, defragerClient)
                    }
                }
            } catch {
                XCTFail("Defrag, unable to create defrager account")
            }
        }
        
        func verifyAccountIsDefragmented(
            defrageeClient: MobileCoinClient,
            completion: @escaping (Bool, UInt64) -> Void
        ) {
            defrageeClient.amountTransferable(tokenId: .MOB) { result in
                guard let fullAmount = try? result.get() else {
                    XCTFail("Defrag unable to calculate full amount")
                    return
                }
                
                print("Defrag full amount available in the defragee account \(fullAmount)")
                
                defrageeClient.requiresDefragmentation(toSendAmount: fullAmount) { result in
                    guard let defragRequired = try? result.get() else {
                        XCTFail("Defrag unable to determine if defrag is required")
                        return
                    }
                    
                    completion(defragRequired, fullAmount)
                }
            }
        }
        
        func defragmentAccount(
            defrageeClient: MobileCoinClient,
            toSendAmount: UInt64,
            completion: @escaping (_ fullAmount: UInt64) -> Void
        ) {
            defrageeClient.prepareDefragmentationStepTransactions(
                toSendAmount: toSendAmount
            ) { result in
                guard let stepTransactions = try? result.get() else {
                    XCTFail("Defrag unable to calculate defrag step transactions")
                    return
                }
                
                let defrageeBalances = defrageeClient.balances
                defrageeClient.submitDefragStepTransactions(
                    transactions: stepTransactions
                ) { result in
                    let feesSpent = McConstants.DEFAULT_MINIMUM_FEE.multipliedReportingOverflow(
                        by: UInt64(stepTransactions.count)
                    ).partialValue
                    let newFullAmount = toSendAmount.subtractingReportingOverflow(feesSpent).partialValue
                    
                    verifyBalanceChange(defrageeClient, defrageeBalances, completion: { _ in
                        completion(newFullAmount)
                    })
                }
            }
        }
        
        func prepareForLoadingDefrager(
            defrageeClient: MobileCoinClient,
            completion: @escaping (_ fullAmount: UInt64) -> Void
        ) {
            verifyAccountIsDefragmented(defrageeClient: defrageeClient) { defragRequired, fullAmount in
                if defragRequired {
                    defragmentAccount(defrageeClient: defrageeClient, toSendAmount: fullAmount) { newFullAmount in
                        completion(newFullAmount)
                    }
                } else {
                    completion(fullAmount)
                }
            }
        }
        
        createBothClients() { (_ defragee: MobileCoinClient, _ defrager: MobileCoinClient) in
            prepareForLoadingDefrager(defrageeClient: defragee) { fullAmount in
                print("Defragee account ready to send full amount to Defrager")
                loadUpDefragerAccount(defrageeClient: defragee, defragerClient: defrager, fullAmount: fullAmount) {
                    print("Defrag, full amount sent from Defragee to Defrager")
                    let preFragmentedDefrageeBalances = defragee.balances
                    fragmentDefrageeAccount(
                        defragee: defragee,
                        defrager: defrager,
                        amount: fullAmount,
                        count: splitFactor,
                        index: 0
                    ) { _ in
                        verifyBalanceChange(defragee, preFragmentedDefrageeBalances) { _ in
                            print("Defragee account should be fragmented")
                            verifyAccountIsDefragmented(defrageeClient: defragee) { defragRequired, fullAmount in
                                guard defragRequired else {
                                    XCTFail("Defrag account should be deframented here")
                                    return
                                }
                                print("Defragee account is fragmented")
                                
                                defragmentAccount(defrageeClient: defragee, toSendAmount: fullAmount) { newFullAmount in
                                    print("Defragee account should be de-fragmented")
                                    verifyAccountIsDefragmented(defrageeClient: defragee) { defragRequired, fullAmount in
                                        guard defragRequired == false else {
                                            XCTFail("Defrag account should NOT be deframented here")
                                            return
                                        }
                                        print("Defragee account is verified de-fragmented")
                                        print("Defrag SUCCESS")
                                        
                                        expect.fulfill()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
#if swift(>=5.5)

    @available(iOS 15.0, *)
    func testDynamicAccountCreation() async throws {
        // try XCTSkip()
        let minFee = IntegrationTestFixtures.fee
         let minMOBUSDFee: UInt64 = 2650

        func verifyBalances(
            client: MobileCoinClient,
            balances: [TokenId:[UInt64]],
            returnAddress: PublicAddress
        ) async throws {
            let clientBals = client.balances
            XCTAssertEqual(clientBals.tokenIds, Set<TokenId>(try XCTUnwrap(balances.keys)))
                        
            for tokenId in clientBals.tokenIds {
                let expectedAmt = try XCTUnwrap(balances[tokenId]).reduce(0, +)
                let clientBal = try XCTUnwrap(clientBals.balances[tokenId])
                let clientAmt = try XCTUnwrap(clientBal.amount())
                XCTAssertEqual(clientAmt, expectedAmt)
                
                while true {
                    let amtTransferable = try await client.amountTransferable(tokenId: tokenId)
                    guard amtTransferable > 0 else {
                        break
                    }

                    let returnAmt = Amount(amtTransferable, in: tokenId)
                    let fee = try await client.estimateTotalFee(
                        toSendAmount: returnAmt,
                        feeLevel: .minimum)

                    let transaction = try await client.prepareTransaction(
                        to: returnAddress,
                        amount: returnAmt,
                        fee: fee)
                    try await client.submitTransaction(transaction: transaction.transaction)
                    
                    var txComplete = false
                    while !txComplete {
                        try await client.updateBalances()
                        let txStatus = try await client.status(of: transaction.transaction)
                        switch txStatus {
                        case .accepted(block: _ ):
                            txComplete = true
                        case .failed:
                            print("Failed to return funds")
                            break
                        case .unknown:
                            // throttle the polling a bit
                            sleep(1)
                        }
                    }
                    
                    try await client.updateBalances()
                }
            }
        }

        let sourceAccountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 0)
        let sourceClient = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountIndex: 0,
            transportProtocol: .http)

        let accountFactory = TestAccountFactory(
            fogReportUrl:  NetworkConfigFixtures.network.fogReportUrl,
            fogAuthoritySpki: try NetworkConfigFixtures.network.fogAuthoritySpki())

        let testAccountConfigs = [
            TestAccountFactory.TestAccountConfig(
                name:"acct0",
                txData:
                    [.MOB : [1 + minFee]]),
            TestAccountFactory.TestAccountConfig(
                name:"acct1",
                txData:
                    [
                        .MOB : [1, 2, minFee],
                        .MOBUSD : [1 , 2, 3, minMOBUSDFee]
                    ]),
            TestAccountFactory.TestAccountConfig(
                name:"acct3",
                txData:[.MOBUSD : [3 + minMOBUSDFee]]),
            TestAccountFactory.TestAccountConfig(
                name:"acct4",
                txData:[.MOBUSD : [4 + minMOBUSDFee]]),
            TestAccountFactory.TestAccountConfig(
                name:"acct5",
                txData:[.MOBUSD : [5 + minMOBUSDFee]]),
            TestAccountFactory.TestAccountConfig(
                name:"acct6",
                txData:[.MOBUSD : [6 + minMOBUSDFee]]),
            TestAccountFactory.TestAccountConfig(
                name:"acct7",
                txData:[.MOBUSD : [7 + minMOBUSDFee]]),
            TestAccountFactory.TestAccountConfig(
                name:"acct8",
                txData:[.MOBUSD : [8 + minMOBUSDFee]]),
            TestAccountFactory.TestAccountConfig(
                name:"acct9",
                txData:[.MOBUSD : [9 + minMOBUSDFee]]),
        ]
        
        let testAccounts = try await accountFactory.makeAccounts(
            sourceClient: sourceClient,
            testAccountConfigs: testAccountConfigs
        )

        XCTAssertEqual(testAccountConfigs.count, testAccounts.count)

        var testClients = [MobileCoinClient]()
        for i in 0..<testAccounts.count {
            let config = testAccountConfigs[i]
            let account = testAccounts[i]
            
            let testClient = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
                accountKey: account.accountKey,
                //tokenId: .MOB,
                tokenId: try XCTUnwrap(config.txData.first).key,
                transportProtocol: .http)
            testClients.append(testClient)
        }
        
        for i in 0..<testAccounts.count {
            let config = testAccountConfigs[i]
            let testClient = testClients[i]

            try await verifyBalances(
                client: testClient,
                balances: config.txData,
                returnAddress: sourceAccountKey.publicAddress)
        }
    }
    
    @available(iOS 15.0, *)
    func testDynamicAccountHasBalance() async throws {
        try XCTSkip()
        let entropyString = "QzNxpAlpc3yCU5qpe92TqhUHCMt0hTDwXplwu//JPiI="

        guard let entropyData = Data(base64Encoded: entropyString, options: []) else {
            XCTFail("can't create entropy from string")
            return
        }

        guard let entropy32 = Data32(entropyData) else {
            XCTFail("can't create entropy32")
            return
        }

        switch AccountKey.make(
            rootEntropy: entropy32.data,
            fogReportUrl: NetworkConfigFixtures.network.fogReportUrl,
            fogReportId: "",
            fogAuthoritySpki: try NetworkConfigFixtures.network.fogAuthoritySpki())
        {
        case .success(let acctKey):
            let sourceClient = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
                accountKey: acctKey,
                tokenId: .MOB,
                transportProtocol: .http)
        case .failure:
            XCTFail("account not created or doesn't have balance")
        }

    }
#endif
    
}
