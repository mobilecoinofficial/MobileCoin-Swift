//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable all

@testable import MobileCoin
import XCTest

class MobileCoinClientInternalIntTests: XCTestCase {

    func testDefragmentationTesting() throws {
        let description = "Defragmentation Testing"
        try testSupportedProtocols(description: description, timeout: 1000) {
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
                print("Defrage updating balance...")
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
            count: Int,
            index: Int,
            completion: @escaping (Result<(), TransactionSubmissionError>) -> Void
        ) {
            guard index != count else {
                completion(.success(()))
                return
            }
            
            let fragmentAmount = amount.dividedReportingOverflow(by: UInt64(splitFactor)).partialValue
            
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
                            fragmentAccount(
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
                        accountIndex: defrageeIndex,
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
        
        func prepareForLoadingDefrager(
            defrageeClient: MobileCoinClient,
            defragerClient: MobileCoinClient,
            completion: @escaping (_ fullAmount: UInt64) -> Void
        ) {
            defrageeClient.amountTransferable(tokenId: .MOB) { result in
                guard let fullAmount = try? result.get() else {
                    XCTFail("Defrag unable to calculate full amount")
                    return
                }
                
                print("Defrag full amount available in the defragee account \(fullAmount)")
                
                defrageeClient.requiresDefragmentation(toSendAmount: fullAmount) { result in
                    guard let defragRequired = try? result.get() else {
                        XCTFail("Defrag unable to calculate full amount")
                        return
                    }
                    
                    if defragRequired {
                        defrageeClient.prepareDefragmentationStepTransactions(
                            toSendAmount: fullAmount
                        ) { result in
                            guard let stepTransactions = try? result.get() else {
                                XCTFail("Defrag unable to calculate defrag step transactions")
                                return
                            }
                            
                            // Defrag account then call completion
                            
                        }
                    } else {
                        // Defrag call completion
                    }
                }
            }
        }
        
        createBothClients() { (_ defragee: MobileCoinClient, _ defrager: MobileCoinClient) in
            prepareForLoadingDefrager(defrageeClient: defragee, defragerClient: defrager) { fullAmount in
                loadUpDefragerAccount(defrageeClient: defragee, defragerClient: defrager, fullAmount: fullAmount) {
                    fragmentAccount(
                        defragee: defragee,
                        defrager: defrager,
                        amount: fullAmount,
                        count: splitFactor,
                        index: 0
                    ) { _ in
                        // verify that account 5 needs to be defragged to send (amount/20)*17
                        // defrag account 5
                        // verify that account 5 does not need to be defragged to send (amount/20)*17
                        expect.fulfill()
                    }
                }
            }
        }
    }
}
