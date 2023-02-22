////
////  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
////
//
//// swiftlint:disable all
//
//@testable import MobileCoin
//import XCTest
//
//class MobileCoinClientInternalIntTests: XCTestCase {
//
//    func testDefragmentationTesting() throws {
////        let description = "Defragmentation Testing"
////        try testSupportedProtocols(description: description, timeout: 250) {
////            try defragmentationTesting(transportProtocol: $0, expectation: $1)
////        }
//    }
//    
//    func defragmentationTesting(
//        transportProtocol: TransportProtocol,
//        expectation expect: XCTestExpectation
//    ) throws {
//        func verifyBalanceChange(
//            _ client: MobileCoinClient,
//            _ balancesBefore: Balances,
//            completion: @escaping (Result<UInt64, InvalidInputError>) -> Void
//        ) {
//            var numChecksRemaining = 5
//            func checkBalanceChange() {
//                numChecksRemaining -= 1
//                print("Defrag updating balance...")
//                client.updateBalances {
//                    guard let balances = $0.successOrFulfill(expectation: expect) else { return }
//                    print("Balances: \(balances)")
//                        
//                    var diff: UInt64 = 0
//                    do {
//                        let balancesMap = balances.balances
//                        let balancesBeforeMap = balancesBefore.balances
//                        let mob = balancesMap[TokenId.MOB]?.amount() ?? 0
//                        let initialMob = try XCTUnwrap(balancesBeforeMap[.MOB]?.amount())
//                        
//                        guard mob != initialMob else {
//                            guard numChecksRemaining > 0 else {
//                                XCTFail("Failed to receive a changed balance. initial balance: " +
//                                        "\(initialMob), current balance: " +
//                                        "\(mob) picoMOB")
//                                expect.fulfill()
//                                return
//                            }
//                            
//                            Thread.sleep(forTimeInterval: 2)
//                            checkBalanceChange()
//                            return
//                        }
//                        diff = 9
//                    } catch {}
//                    completion(.success(diff))
//                }
//            }
//            checkBalanceChange()
//        }
//        
//        // Figure out full spendable amount of coins in 5
//        // Defragment account 5 if necc.
//        // Send all coins from account 5 to
//        // Fragment Accoutn by submitting 20 transactions of (full-amount/20) from 6 to 5
//        // verify that account 5 needs to be defragged to send full amount ...
//        //     (now in 20 txOuts, but 16 is our Transaction Max, so defrag required should be true)
//        //
//        // defrag account 5
//        // verify that account 5 does not need to be defragged to send full-amount, success.
//
//        let defrageeIndex = 5
//        let defragerIndex = 6
//        
//        let splitFactor = McConstants.MAX_INPUTS + 4
//        
//        let defrageeAccount = try IntegrationTestFixtures.createAccountKey(accountIndex: defrageeIndex)
//        let defragerAccount = try IntegrationTestFixtures.createAccountKey(accountIndex: defragerIndex)
//        
//        func fragmentDefrageeAccount(
//            defragee: MobileCoinClient,
//            defrager: MobileCoinClient,
//            amount: UInt64,
//            count: Int,
//            index: Int,
//            completion: @escaping (Result<(), TransactionSubmissionError>) -> Void
//        ) {
//            guard index != count else {
//                completion(.success(()))
//                return
//            }
//            
//            let fragmentAmount = amount.dividedReportingOverflow(by: UInt64(splitFactor)).partialValue
//            
//            print("Defrag, defragee account is being fragmented by the Defrager")
//            print("Defrag transaction preperation")
//            defrager.prepareTransaction(
//                to: defrageeAccount.publicAddress,
//                amount: fragmentAmount,
//                fee: IntegrationTestFixtures.fee
//            ) {
//                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
//                else { return }
//                
//                print("Defrag transaction preperation successful")
//                let defragerBalances = defrager.balances
//                defrager.submitTransaction(transaction) {
//                    guard $0.successOrFulfill(expectation: expect) != nil else { return }
//                    
//                    print("Defrag transaction submission successful")
//                    
//                    verifyBalanceChange(defrager, defragerBalances) { _ in
//                        defrager.updateBalances() { _ in
//                            fragmentDefrageeAccount(
//                                defragee: defragee,
//                                defrager: defrager,
//                                amount: amount,
//                                count: count,
//                                index: (index + 1),
//                                completion: completion
//                            )
//                        }
//                    }
//                }
//            }
//        }
//
//        func loadUpDefragerAccount(
//            defrageeClient: MobileCoinClient,
//            defragerClient: MobileCoinClient,
//            fullAmount: UInt64,
//            completion: @escaping () -> Void
//        ) {
//            defrageeClient.prepareTransaction(
//                to: defragerAccount.publicAddress,
//                amount: fullAmount,
//                fee: IntegrationTestFixtures.fee
//            ) {
//                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
//                else { return }
//                
//                let defragerBalances = defragerClient.balances
//                let defrageeBalances = defrageeClient.balances
//                defrageeClient.submitTransaction(transaction) {
//                    guard $0.successOrFulfill(expectation: expect) != nil else { return }
//                    
//                    print("Defrag transaction submission successful")
//                    
//                    verifyBalanceChange(defragerClient, defragerBalances, completion: { _ in
//                        verifyBalanceChange(defrageeClient, defrageeBalances, completion: { _ in
//                            completion()
//                        })
//                    })
//                }
//            }
//        }
//        
//        func createBothClients(
//            completion: @escaping (_ defragee: MobileCoinClient, _ defrager: MobileCoinClient) -> Void
//        ) {
//            do {
//                try IntegrationTestFixtures.createMobileCoinClientWithBalance(
//                    accountIndex: defragerIndex,
//                    expectation: expect,
//                    transportProtocol: transportProtocol)
//                { defragerClient in
//                    try? IntegrationTestFixtures.createMobileCoinClientWithBalance(
//                        accountIndex: defrageeIndex,
//                        expectation: expect,
//                        transportProtocol: transportProtocol)
//                    { defrageeClient in
//                        completion(defrageeClient, defragerClient)
//                    }
//                }
//            } catch {
//                XCTFail("Defrag, unable to create defrager account")
//            }
//        }
//        
//        func verifyAccountIsDefragmented(
//            defrageeClient: MobileCoinClient,
//            completion: @escaping (Bool, UInt64) -> Void
//        ) {
//            defrageeClient.amountTransferable(tokenId: .MOB) { result in
//                guard let fullAmount = try? result.get() else {
//                    XCTFail("Defrag unable to calculate full amount")
//                    return
//                }
//                
//                print("Defrag full amount available in the defragee account \(fullAmount)")
//                
//                defrageeClient.requiresDefragmentation(toSendAmount: fullAmount) { result in
//                    guard let defragRequired = try? result.get() else {
//                        XCTFail("Defrag unable to calculate full amount")
//                        return
//                    }
//                    
//                    completion(defragRequired, fullAmount)
//                }
//            }
//        }
//        
//        func defragmentAccount(
//            defrageeClient: MobileCoinClient,
//            toSendAmount: UInt64,
//            completion: @escaping (_ fullAmount: UInt64) -> Void
//        ) {
//            defrageeClient.prepareDefragmentationStepTransactions(
//                toSendAmount: toSendAmount
//            ) { result in
//                guard let stepTransactions = try? result.get() else {
//                    XCTFail("Defrag unable to calculate defrag step transactions")
//                    return
//                }
//                
//                let defrageeBalances = defrageeClient.balances
//                defrageeClient.submitDefragStepTransactions(
//                    transactions: stepTransactions
//                ) { result in
//                    let feesSpent = McConstants.DEFAULT_MINIMUM_FEE.multipliedReportingOverflow(
//                        by: UInt64(stepTransactions.count)
//                    ).partialValue
//                    let newFullAmount = toSendAmount.subtractingReportingOverflow(feesSpent).partialValue
//                    
//                    verifyBalanceChange(defrageeClient, defrageeBalances, completion: { _ in
//                        completion(newFullAmount)
//                    })
//                }
//            }
//        }
//        
//        func prepareForLoadingDefrager(
//            defrageeClient: MobileCoinClient,
//            completion: @escaping (_ fullAmount: UInt64) -> Void
//        ) {
//            verifyAccountIsDefragmented(defrageeClient: defrageeClient) { defragRequired, fullAmount in
//                if defragRequired {
//                    defragmentAccount(defrageeClient: defrageeClient, toSendAmount: fullAmount) { newFullAmount in
//                        completion(newFullAmount)
//                    }
//                } else {
//                    completion(fullAmount)
//                }
//            }
//        }
//        
//        createBothClients() { (_ defragee: MobileCoinClient, _ defrager: MobileCoinClient) in
//            prepareForLoadingDefrager(defrageeClient: defragee) { fullAmount in
//                print("Defragee account ready to send full amount to Defrager")
//                loadUpDefragerAccount(defrageeClient: defragee, defragerClient: defrager, fullAmount: fullAmount) {
//                    print("Defrag, full amount sent from Defragee to Defrager")
//                    let preFragmentedDefrageeBalances = defragee.balances
//                    fragmentDefrageeAccount(
//                        defragee: defragee,
//                        defrager: defrager,
//                        amount: fullAmount,
//                        count: splitFactor,
//                        index: 0
//                    ) { _ in
//                        verifyBalanceChange(defragee, preFragmentedDefrageeBalances) { _ in
//                            print("Defragee account should be fragmented")
//                            verifyAccountIsDefragmented(defrageeClient: defragee) { defragRequired, fullAmount in
//                                guard defragRequired else {
//                                    XCTFail("Defrag account should be deframented here")
//                                    return
//                                }
//                                print("Defragee account is fragmented")
//                                
//                                defragmentAccount(defrageeClient: defragee, toSendAmount: fullAmount) { newFullAmount in
//                                    print("Defragee account should be de-fragmented")
//                                    verifyAccountIsDefragmented(defrageeClient: defragee) { defragRequired, fullAmount in
//                                        guard defragRequired == false else {
//                                            XCTFail("Defrag account should NOT be deframented here")
//                                            return
//                                        }
//                                        print("Defragee account is verified de-fragmented")
//                                        print("Defrag SUCCESS")
//                                        
//                                        expect.fulfill()
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
