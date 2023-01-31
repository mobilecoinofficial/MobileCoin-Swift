//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable all

import MobileCoin
import XCTest

class MobileCoinClientInternalIntTests: XCTestCase {

    func testDefragmentationTesting() throws {
        let description = "Defragmentation Testing"
        try testSupportedProtocols(description: description) {
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
                print("Updating balance...")
                client.updateBalances {
                    guard let balances = $0.successOrFulfill(expectation: expect) else { return }
                    print("Balances: \(balances)")
                        
                    let diff: UInt64 = {
                        do {
                            let balancesMap = balances.balances
                            let balancesBeforeMap = balancesBefore.balances
                            let mobUSD = try XCTUnwrap(balancesMap[TokenId.MOBUSD]?.amount())
                            let initialMobUSD = try XCTUnwrap(balancesBeforeMap[.MOBUSD]?.amount())
                            
                            guard mobUSD != initialMobUSD else {
                                guard numChecksRemaining > 0 else {
                                    XCTFail("Failed to receive a changed balance. initial balance: " +
                                            "\(initialMobUSD), current balance: " +
                                            "\(mobUSD) microMOBUSD")
                                    expect.fulfill()
                                    return
                                }
                                
                                Thread.sleep(forTimeInterval: 2)
                                checkBalanceChange()
                                return
                            }
                            return max(mobUSD, initialMobUSD)
                                .subtractingReportingOverflow(min(mobUSD, initialMobUSD)).partialValue
                        } catch {}
                    }()
                    completion(.success(diff))
                }
            }
            checkBalanceChange()
        }
        
        // Store amount of coins in 5
        // Send all coins from account 5 to 6
        // submit amount/20 transactions from 6 to 5
        // verify that account 5 needs to be defragged to send (amount/20)*17
        // defrag account 5
        // verify that account 5 does not need to be defragged to send (amount/20)*17
        

        let defrageeIndex = 5
        let defragerIndex = 6
        
        // let splitFactor = McConstants.MAX_INPUTS + 4
        let splitFactor = 16 + 4
        
        let defrageeAccount = try IntegrationTestFixtures.createAccountKey(accountIndex: defrageeIndex)
        let defragerAccount = try IntegrationTestFixtures.createAccountKey(accountIndex: defragerIndex)
        
        let serialQueue = DispatchQueue(label: "com.mobilecoin.defragmentationTesting")

        func fragmentAccount(
            defragee: MobileCoinClient,
            defrager: MobileCoinClient,
            amount: UInt64,
            completion: @escaping (Result<(), TransactionSubmissionError>) -> Void
        ) {
            Array(repeating: 0, count: splitFactor).map { _ in
                amount.dividedReportingOverflow(by: UInt64(splitFactor)).partialValue
            }
            .mapAsync({ fragmentAmount, callback in
                defrager.prepareTransaction(
                    to: defrageeAccount.publicAddress,
                    amount: fragmentAmount,
                    fee: IntegrationTestFixtures.fee
                ) {
                    guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                    else { return }
                    
                    let defragerBalances = defrager.balances
                    defrager.submitTransaction(transaction) {
                        guard $0.successOrFulfill(expectation: expect) != nil else { return }
                        
                        print("Transaction submission successful")
                        
                        verifyBalanceChange(defrager, defragerBalances, completion: callback)
                    }
                }
            },
            serialQueue: serialQueue,
            completion: { diffs in
                print("diffs from having the defrager fragment the account \(diffs)")
                
                // verify that account 5 needs to be defragged to send (amount/20)*17
                // defrag account 5
                // verify that account 5 does not need to be defragged to send (amount/20)*17
            })

        }

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
                accountIndex: defragerIndex,
                expectation: expect,
                transportProtocol: transportProtocol)
        { defragerClient in
            try? IntegrationTestFixtures.createMobileCoinClientWithBalance(
                accountIndex: defrageeIndex,
                expectation: expect,
                transportProtocol: transportProtocol)
            { defrageeClient in
                defrageeClient.amountTransferable(tokenId: .MOB, completion: { result in
                    guard let fullAmount = try? result.get() else {
                        XCTFail("Unable to calculate full amount")
                        return
                    }
                    
                    print("Full amount available in the defragee account \(fullAmount)")
                    
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
                            
                            print("Transaction submission successful")
                        
                            verifyBalanceChange(defragerClient, defragerBalances, completion: { _ in
                                verifyBalanceChange(defrageeClient, defrageeBalances, completion: { _ in
                                    fragmentAccount(
                                        defragee: defrageeClient,
                                        defrager: defragerClient,
                                        amount: fullAmount
                                    ) { _ in
                                        
                                    }
                                })
                            })
                        }
                    }
                })
            }
        }

        
            
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
                expectation: expect,
                transportProtocol: transportProtocol)
        { client in
            client.prepareTransaction(
                to: recipient,
                amount: 100,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                else { return }

                print("transaction fixture: \(transaction.serializedData.hexEncodedString())")

                client.submitTransaction(transaction) {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }

                    print("Transaction submission successful")
                    expect.fulfill()
                }
            }
        }
    }

}
