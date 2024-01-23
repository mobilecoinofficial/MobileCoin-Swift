//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable file_length function_parameter_count multiline_arguments
// swiftlint:disable prefixed_toplevel_constant type_body_length
// swiftlint:disable vertical_parameter_alignment_on_call

@testable import MobileCoin
import XCTest

private let minFee: UInt64 = 400_000_000

class DefaultTxOutSelectionStrategyTests: XCTestCase {

    // Test vectors from the Rust fog-sample-paykit
    static let inputs = [1, 1, 1, 4, 9, 1, 1, 1, 19, 2, 1].enumerated()
        .map { SelectionTxOut(value: $0.element, blockIndex: UInt64($0.offset)) }
    fileprivate static let payKitTestCases = [
        // Test vectors from input_selection_heuristic_3_inputs in the Rust fog-sample-paykit
        t1(1, 0, inputs, maxInputs: 3, [0, 1, 2]), // Previously [0]
        t1(2, 0, inputs, maxInputs: 3, [0, 1, 2]), // Previously [0, 1]
        t1(3, 0, inputs, maxInputs: 3, [0, 1, 2]),
        t1(4, 0, inputs, maxInputs: 3, [0, 1, 3]),
        t1(5, 0, inputs, maxInputs: 3, [0, 1, 3]),
        t1(6, 0, inputs, maxInputs: 3, [0, 1, 3]),
        t1(7, 0, inputs, maxInputs: 3, [0, 1, 4]),
        t1(8, 0, inputs, maxInputs: 3, [0, 1, 4]),
        t1(9, 0, inputs, maxInputs: 3, [0, 1, 4]),
        t1(10, 0, inputs, maxInputs: 3, [0, 1, 4]),
        t1(11, 0, inputs, maxInputs: 3, [0, 1, 4]),
        t1(12, 0, inputs, maxInputs: 3, [0, 1, 8]),
        t1(13, 0, inputs, maxInputs: 3, [0, 1, 8]),
        t1(14, 0, inputs, maxInputs: 3, [0, 1, 8]),
        t1(15, 0, inputs, maxInputs: 3, [0, 1, 8]),
        t1(16, 0, inputs, maxInputs: 3, [0, 1, 8]),
        t1(17, 0, inputs, maxInputs: 3, [0, 1, 8]),
        t1(18, 0, inputs, maxInputs: 3, [0, 1, 8]),
        t1(19, 0, inputs, maxInputs: 3, [0, 1, 8]),
        t1(20, 0, inputs, maxInputs: 3, [0, 1, 8]),
        t1(21, 0, inputs, maxInputs: 3, [0, 1, 8]),
        t1(22, 0, inputs, maxInputs: 3, [0, 3, 8]),
        t1(23, 0, inputs, maxInputs: 3, [0, 3, 8]),
        t1(24, 0, inputs, maxInputs: 3, [0, 3, 8]),
        t1(25, 0, inputs, maxInputs: 3, [0, 4, 8]),
        t1(26, 0, inputs, maxInputs: 3, [0, 4, 8]),
        t1(27, 0, inputs, maxInputs: 3, [0, 4, 8]),
        t1(28, 0, inputs, maxInputs: 3, [0, 4, 8]),
        t1(29, 0, inputs, maxInputs: 3, [0, 4, 8]),
        t1(30, 0, inputs, maxInputs: 3, [3, 4, 8]),
        t1(31, 0, inputs, maxInputs: 3, [3, 4, 8]),
        t1(32, 0, inputs, maxInputs: 3, [3, 4, 8]),

        // Test vectors from input_selection_heuristic_4_inputs in the Rust fog-sample-paykit
        t1(1, 0, inputs, maxInputs: 4, [0, 1, 2, 3]), // Previously [0]
        t1(2, 0, inputs, maxInputs: 4, [0, 1, 2, 3]), // Previously [0, 1]
        t1(3, 0, inputs, maxInputs: 4, [0, 1, 2, 3]), // Previously [0, 1, 2]
        t1(4, 0, inputs, maxInputs: 4, [0, 1, 2, 3]),
        t1(5, 0, inputs, maxInputs: 4, [0, 1, 2, 3]),
        t1(6, 0, inputs, maxInputs: 4, [0, 1, 2, 3]),
        t1(7, 0, inputs, maxInputs: 4, [0, 1, 2, 3]),
        t1(8, 0, inputs, maxInputs: 4, [0, 1, 2, 4]),
        t1(9, 0, inputs, maxInputs: 4, [0, 1, 2, 4]),
        t1(10, 0, inputs, maxInputs: 4, [0, 1, 2, 4]),
        t1(11, 0, inputs, maxInputs: 4, [0, 1, 2, 4]),
        t1(12, 0, inputs, maxInputs: 4, [0, 1, 2, 4]),
        t1(13, 0, inputs, maxInputs: 4, [0, 1, 2, 8]),
        t1(14, 0, inputs, maxInputs: 4, [0, 1, 2, 8]),
        t1(15, 0, inputs, maxInputs: 4, [0, 1, 2, 8]),
        t1(16, 0, inputs, maxInputs: 4, [0, 1, 2, 8]),
        t1(17, 0, inputs, maxInputs: 4, [0, 1, 2, 8]),
        t1(18, 0, inputs, maxInputs: 4, [0, 1, 2, 8]),
        t1(19, 0, inputs, maxInputs: 4, [0, 1, 2, 8]),
        t1(20, 0, inputs, maxInputs: 4, [0, 1, 2, 8]),
        t1(21, 0, inputs, maxInputs: 4, [0, 1, 2, 8]),
        t1(22, 0, inputs, maxInputs: 4, [0, 1, 2, 8]),
        t1(23, 0, inputs, maxInputs: 4, [0, 1, 3, 8]),
        t1(24, 0, inputs, maxInputs: 4, [0, 1, 3, 8]),
        t1(25, 0, inputs, maxInputs: 4, [0, 1, 3, 8]),
        t1(26, 0, inputs, maxInputs: 4, [0, 1, 4, 8]),
        t1(27, 0, inputs, maxInputs: 4, [0, 1, 4, 8]),
        t1(28, 0, inputs, maxInputs: 4, [0, 1, 4, 8]),
        t1(29, 0, inputs, maxInputs: 4, [0, 1, 4, 8]),
        t1(30, 0, inputs, maxInputs: 4, [0, 1, 4, 8]),
        t1(31, 0, inputs, maxInputs: 4, [0, 3, 4, 8]),
        t1(32, 0, inputs, maxInputs: 4, [0, 3, 4, 8]),
        t1(33, 0, inputs, maxInputs: 4, [0, 3, 4, 8]),
        t1(34, 0, inputs, maxInputs: 4, [3, 4, 8, 9]),
    ]

    func testSelectTransactionInputs() {
        let sut = DefaultTxOutSelectionStrategy()
        var testCases: [TestCase1] = [
            t1(10000, 1000, [.init(value: 11000, blockIndex: 0)], [0]),
            t1(10000, 1000, [
                .init(value: 7000, blockIndex: 0),
                .init(value: 4000, blockIndex: 0),
            ], [0, 1]),
            t1(10000, 1000, [
                .init(value: 7000, blockIndex: 0),
                .init(value: 4000, blockIndex: 0),
                .init(value: 0, blockIndex: 0),
            ], [0, 1]),
            t1(10000, 1000, [
                .init(value: 0, blockIndex: 0),
                .init(value: 7000, blockIndex: 0),
                .init(value: 4000, blockIndex: 0),
            ], [1, 2]),
            t1(10000, 1000, [
                .init(value: 7000, blockIndex: 2),
                .init(value: 4000, blockIndex: 1),
                .init(value: 0, blockIndex: 0),
            ], [0, 1]),
            t1(10000, 1000, [
                .init(value: 0, blockIndex: 0),
                .init(value: 7000, blockIndex: 1),
                .init(value: 4000, blockIndex: 2),
            ], [1, 2]),
            t1(10000, 1000, [
                .init(value: 10000, blockIndex: 0),
                .init(value: 1000, blockIndex: 0),
            ], [0, 1]),
            t1(UInt64.max, 1000, [
                .init(value: UInt64.max, blockIndex: 0),
                .init(value: UInt64.max, blockIndex: 0),
            ], [0, 1]),
            t1(UInt64.max, UInt64.max, [
                .init(value: UInt64.max, blockIndex: 0),
                .init(value: UInt64.max - 1, blockIndex: 0),
                .init(value: UInt64.max, blockIndex: 0),
            ], [0, 1, 2]),
            t1(UInt64.max, UInt64.max, [
                .init(value: UInt64.max, blockIndex: 0),
                .init(value: UInt64.max - 1, blockIndex: 0),
                .init(value: UInt64.max - 1, blockIndex: 0),
            ], [0, 1, 2]),
            t1(UInt64.max, UInt64.max, [
                .init(value: UInt64.max, blockIndex: 0),
                .init(value: UInt64.max - 1, blockIndex: 0),
                .init(value: 1, blockIndex: 0),
                .init(value: UInt64.max, blockIndex: 0),
            ]),
            t1(15000, 1000, (0..<17).map { .init(value: 1000, blockIndex: UInt64($0)) }),
            t1(15000, 1000, (0..<17).map { .init(value: 1000, blockIndex: UInt64(17 - $0)) }),
        ]
        testCases.append(contentsOf: Self.payKitTestCases)

        for (amount, fee, txOuts, maxInputs, expectedIds, file, line) in testCases {
            _ = try? {
                let selectedIds = try XCTUnwrapSuccess(
                    sut.selectTransactionInputs(amount: Amount(mob: amount),
                                                fee: fee,
                                                fromTxOuts: txOuts,
                                                maxInputs: maxInputs),
                        file: file, line: line)
                checkSelectionIds(selectedIds: selectedIds, minTotalOutput: [amount, fee],
                    txOuts: txOuts, maxInputs: maxInputs, file: file, line: line)
                if let expectedIds = expectedIds {
                    XCTAssertEqual(Set(selectedIds), Set(expectedIds), file: file, line: line)
                }
            }()
        }
    }

    func testSelectTransactionInputsThrows() {
        let sut = DefaultTxOutSelectionStrategy()
        let txOutTestCases: [(amount: UInt64, fee: UInt64, [SelectionTxOut])] = [
            (10000, 1000, [.init(value: 10999, blockIndex: 0)]),
        ]
        for (amount, fee, txOuts) in txOutTestCases {
            XCTAssertFailure(
                sut.selectTransactionInputs(
                    amount: Amount(mob: amount),
                    fee: fee,
                    fromTxOuts: txOuts))
        }
    }

    func testSelectTransactionInputsThrowsDefragNeeded() {
        let sut = DefaultTxOutSelectionStrategy()
        let inputs = [1, 1, 1, 4, 9, 1, 1, 1, 19, 2, 1].enumerated()
            .map { SelectionTxOut(value: $0.element, blockIndex: UInt64($0.offset)) }
        let txOutTestCases: [TestCase1] = [
            // Test vectors from input_selection_heuristic_3_inputs in the Rust fog-sample-paykit
            t1(33, 0, inputs, maxInputs: 3),
            t1(34, 0, inputs, maxInputs: 3),
            t1(40, 0, inputs, maxInputs: 3),
            t1(41, 0, inputs, maxInputs: 3),
            // Test vectors from input_selection_heuristic_4_inputs in the Rust fog-sample-paykit
            t1(35, 0, inputs, maxInputs: 4),
            t1(36, 0, inputs, maxInputs: 4),
            t1(37, 0, inputs, maxInputs: 4),
            t1(40, 0, inputs, maxInputs: 4),
            t1(41, 0, inputs, maxInputs: 4),
        ]
        for (amount, fee, txOuts, maxInputs, _, file, line) in txOutTestCases {
            _ = try? {
                let error = try XCTUnwrapFailure(
                    sut.selectTransactionInputs(
                        amount: Amount(mob: amount),
                        fee: fee,
                        fromTxOuts: txOuts,
                        maxInputs: maxInputs),
                    file: file, line: line)
                if case .defragmentationRequired = error {
                } else {
                    XCTFail("error not .defragmentationRequired: \(error)", file: file, line: line)
                }
            }()
        }
    }

    func testSelectTransactionInputsThrowsInsufficientFunds() {
        let sut = DefaultTxOutSelectionStrategy()
        let inputs = [1, 1, 1, 4, 9, 1, 1, 1, 19, 2, 1].enumerated()
            .map { SelectionTxOut(value: $0.element, blockIndex: UInt64($0.offset)) }
        let txOutTestCases: [TestCase1] = [
            // Test vectors from input_selection_heuristic_3_inputs in the Rust fog-sample-paykit
            t1(42, 0, inputs, maxInputs: 3),
            // Test vectors from input_selection_heuristic_4_inputs in the Rust fog-sample-paykit
            t1(42, 0, inputs, maxInputs: 4),
        ]
        for (amount, fee, txOuts, maxInputs, _, file, line) in txOutTestCases {
            _ = try? {
                let error = try XCTUnwrapFailure(
                    sut.selectTransactionInputs(
                        amount: Amount(mob: amount),
                        fee: fee,
                        fromTxOuts: txOuts,
                        maxInputs: maxInputs),
                    file: file, line: line)
                if case .insufficientTxOuts = error {
                } else {
                    XCTFail("error not .insufficientTxOuts: \(error)", file: file, line: line)
                }
            }()
        }
    }

    private let nonDefragTestCases: [TestCase3] = [
        t3(1000, [.init(value: minFee + 1000)], expectedTotalFee: minFee),
        t3(1000, [
            .init(value: (minFee + 1000) / 4),
            .init(value: (minFee + 1000) / 4),
            .init(value: (minFee + 1000) / 4),
            .init(value: (minFee + 1000) / 4),
        ], maxInputsPerTransaction: 4, expectedTotalFee: minFee),
    ]

    private let defragTestCases: [TestCase3] = [
        t3(100_000_000_000, [
            .init(value: (2 * minFee + 100_000_000_000) / 4),
            .init(value: (2 * minFee + 100_000_000_000) / 4),
            .init(value: (2 * minFee + 100_000_000_000) / 4),
            .init(value: (2 * minFee + 100_000_000_000) / 4),
        ], maxInputsPerTransaction: 3, expectedTotalFee: 2 * minFee),
    ]

    private let insufficientFundsTestCases: [TestCase3] = [
        t3(1000, []),
        t3(1000, [.init(value: 100000)]),
        t3(1000, [.init(value: minFee + 999)]),
        t3(1000, [
            .init(value: (minFee + 1000) / 4),
            .init(value: (minFee + 1000) / 4),
            .init(value: (minFee + 1000) / 4),
            .init(value: (minFee + 1000) / 4),
        ], maxInputsPerTransaction: 3, expectedTotalFee: minFee),
    ]

    func testAmountTransferable() {
        let sut = DefaultTxOutSelectionStrategy()
        var testCases: [TestCase2] = [
            t2([], expectedAmountTransferable: 0),
            t2([.init(value: minFee + 999)], expectedAmountTransferable: 999),
            t2([
                .init(value: (2 * minFee + 100_000_000_000) / 4),
                .init(value: (2 * minFee + 100_000_000_000) / 4),
                .init(value: (2 * minFee + 100_000_000_000) / 4),
                .init(value: (2 * minFee + 100_000_000_000) / 4),
            ], maxInputsPerTransaction: 3, expectedAmountTransferable: 100_000_000_000),
            t2([
                .init(value: (2 * minFee + 100_000_000_000) / 4),
                .init(value: (2 * minFee + 100_000_000_000) / 4),
                .init(value: (2 * minFee + 100_000_000_000) / 4),
                .init(value: (2 * minFee + 100_000_000_000) / 4),
            ], maxInputsPerTransaction: 4, expectedAmountTransferable: minFee + 100_000_000_000),
        ]
        testCases.append(contentsOf: nonDefragTestCases.map {
            t2($0.feeLevel, $0.txOuts, maxInputsPerTransaction: $0.maxInputsPerTransaction,
               expectedAmountTransferable: $0.expectedAmountTransferable,
               file: $0.file, line: $0.line)
        })
        testCases.append(contentsOf: defragTestCases.map {
            t2($0.feeLevel, $0.txOuts, maxInputsPerTransaction: $0.maxInputsPerTransaction,
               expectedAmountTransferable: $0.expectedAmountTransferable,
               file: $0.file, line: $0.line)
        })

        for (feeLevel, txOuts, maxInputsPerTransaction, expectedAmountTransferable, file, line) in
            testCases
        {
            _ = try? {
                let amountTransferable = try XCTUnwrapSuccess(
                    sut.amountTransferable(
                        feeStrategy: feeLevel.defaultFeeStrategy,
                        txOuts: txOuts,
                        maxInputsPerTransaction: maxInputsPerTransaction),
                    file: file, line: line)
                if let expectedAmountTransferable = expectedAmountTransferable {
                    XCTAssertEqual(amountTransferable, expectedAmountTransferable,
                        "amount transferable != expected amount transferable",
                        file: file, line: line)
                }
            }()
        }
    }

    func testAmountTransferableLargeTxOuts() {
        let sut = DefaultTxOutSelectionStrategy()
        
        let fee = minFee
        let (maxMinusOneFee, overflow) = UInt64.max.subtractingReportingOverflow(McConstants.DEFAULT_MINIMUM_FEE)
        guard overflow == false else { XCTFail("Overflowed calculating expected amount"); return }
        var testCases: [TestCase2] = [
//            t2([], expectedAmountTransferable: BigUInt(0)),
//            t2([.init(value: minFee + 999)], expectedAmountTransferable: BigUInt(999)),
            t2([
                .init(value: (18_446_000_000_000_000_000)),
                .init(value: (18_446_000_000_000_000_000)),
                .init(value: (18_446_000_000_000_000_000)),
                .init(value: (18_446_000_000_000_000_000)),
                .init(value: (18_446_000_000_000_000_000)),
                .init(value: (18_446_000_000_000_000_000)),
                .init(value: (18_446_000_000_000_000_000)),
                .init(value: (18_446_000_000_000_000_000)),
                .init(value: (18_446_000_000_000_000_000)),
                .init(value: (18_446_000_000_000_000_000)),
            ], maxInputsPerTransaction: 3, expectedAmountTransferable: maxMinusOneFee),
//            t2([
//                .init(value: (2 * minFee + 100_000_000_000) / 4),
//                .init(value: (2 * minFee + 100_000_000_000) / 4),
//                .init(value: (2 * minFee + 100_000_000_000) / 4),
//                .init(value: (2 * minFee + 100_000_000_000) / 4),
//            ], maxInputsPerTransaction: 4, expectedAmountTransferable: BigUInt(minFee + 100_000_000_000)),
        ]
        
//        testCases.append(contentsOf: nonDefragTestCases.map {
//            t5($0.feeLevel, $0.txOuts, maxInputsPerTransaction: $0.maxInputsPerTransaction,
//               expectedAmountTransferable: BigUInt($0.expectedAmountTransferable),
//               file: $0.file, line: $0.line)
//        })
//        testCases.append(contentsOf: defragTestCases.map {
//            t5($0.feeLevel, $0.txOuts, maxInputsPerTransaction: $0.maxInputsPerTransaction,
//               expectedAmountTransferable: BigUInt($0.expectedAmountTransferable),
//               file: $0.file, line: $0.line)
//        })
        
        // UInt64.max == 18_446_744_073_709_551_615
        //               18_446_744_072_909_551_615

        for (feeLevel, txOuts, maxInputsPerTransaction, expectedAmountTransferable, file, line) in
            testCases
        {
            _ = try? {
                let amountTransferable = try XCTUnwrapSuccess(
                    sut.amountTransferable(
                        feeStrategy: feeLevel.defaultFeeStrategy,
                        txOuts: txOuts,
                        maxInputsPerTransaction: maxInputsPerTransaction),
                    file: file, line: line)
                if let expectedAmountTransferable = expectedAmountTransferable {
                    let diff = expectedAmountTransferable.subtractingReportingOverflow(amountTransferable)
                    print(diff)
                    XCTAssertEqual(amountTransferable, expectedAmountTransferable,
                        "amount transferable != expected amount transferable",
                        file: file, line: line)
                }
            }()
        }
    }
    
    func testAmountTransferableManyLargeTxOuts() {
        let sut = DefaultTxOutSelectionStrategy()
        
        let fee = minFee
        let (maxMinusThreeFees, overflow) = UInt64.max.subtractingReportingOverflow(McConstants.DEFAULT_MINIMUM_FEE * 3)
        guard overflow == false else { XCTFail("Overflowed calculating expected amount"); return }
        var testCases: [TestCase2] = [
//            t2([], expectedAmountTransferable: BigUInt(0)),
//            t2([.init(value: minFee + 999)], expectedAmountTransferable: BigUInt(999)),
            t2([
                // 39 values, max inputs == 16, expect 3 fees to send all
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
                .init(value: (1_000_000_000_000_000_000)),
            ], maxInputsPerTransaction: 16, expectedAmountTransferable: maxMinusThreeFees),
//            t2([
//                .init(value: (2 * minFee + 100_000_000_000) / 4),
//                .init(value: (2 * minFee + 100_000_000_000) / 4),
//                .init(value: (2 * minFee + 100_000_000_000) / 4),
//                .init(value: (2 * minFee + 100_000_000_000) / 4),
//            ], maxInputsPerTransaction: 4, expectedAmountTransferable: BigUInt(minFee + 100_000_000_000)),
        ]
        
//        testCases.append(contentsOf: nonDefragTestCases.map {
//            t5($0.feeLevel, $0.txOuts, maxInputsPerTransaction: $0.maxInputsPerTransaction,
//               expectedAmountTransferable: BigUInt($0.expectedAmountTransferable),
//               file: $0.file, line: $0.line)
//        })
//        testCases.append(contentsOf: defragTestCases.map {
//            t5($0.feeLevel, $0.txOuts, maxInputsPerTransaction: $0.maxInputsPerTransaction,
//               expectedAmountTransferable: BigUInt($0.expectedAmountTransferable),
//               file: $0.file, line: $0.line)
//        })
        
        // UInt64.max == 18_446_744_073_709_551_615
        //               18_446_744_072_909_551_615

        for (feeLevel, txOuts, maxInputsPerTransaction, expectedAmountTransferable, file, line) in
            testCases
        {
            _ = try? {
                let amountTransferable = try XCTUnwrapSuccess(
                    sut.amountTransferable(
                        feeStrategy: feeLevel.defaultFeeStrategy,
                        txOuts: txOuts,
                        maxInputsPerTransaction: maxInputsPerTransaction),
                    file: file, line: line)
                if let expectedAmountTransferable = expectedAmountTransferable {
                    let diff = expectedAmountTransferable.subtractingReportingOverflow(amountTransferable)
                    print(diff)
                    XCTAssertEqual(amountTransferable, expectedAmountTransferable,
                        "amount transferable != expected amount transferable",
                        file: file, line: line)
                }
            }()
        }
    }
    
    
    func testAmountTransferableThrowsInsufficientTxOuts() {
        let sut = DefaultTxOutSelectionStrategy()
        let testCases: [TestCase2] = [
            t2([.init(value: 100000)]),
            t2([
                .init(value: (minFee + 1000) / 4),
                .init(value: (minFee + 1000) / 4),
                .init(value: (minFee + 1000) / 4),
                .init(value: (minFee + 1000) / 4),
            ], maxInputsPerTransaction: 3),
        ]

        for (feeLevel, txOuts, maxInputsPerTransaction, _, file, line) in testCases {
            _ = try? {
                let error = try XCTUnwrapFailure(
                    sut.amountTransferable(
                        feeStrategy: feeLevel.defaultFeeStrategy,
                        txOuts: txOuts,
                        maxInputsPerTransaction: maxInputsPerTransaction),
                    file: file, line: line)
                if case .feeExceedsBalance = error {
                } else {
                    XCTFail("error not .feeExceedsBalance: \(error)", file: file, line: line)
                }
            }()
        }
    }

    func testEstimateTotalFee() {
        let sut = DefaultTxOutSelectionStrategy()
        var testCases: [TestCase3] = []
        testCases.append(contentsOf: nonDefragTestCases)
        testCases.append(contentsOf: defragTestCases)

        for (amount, feeLevel, txOuts, maxInputsPerTransaction, _, expectedTotalFee, _,
             file, line) in testCases
        {
            _ = try? {
                let (totalFee, _) = try XCTUnwrapSuccess(
                    sut.estimateTotalFee(
                        toSendAmount: Amount(mob: amount),
                        feeStrategy: feeLevel.defaultFeeStrategy,
                        txOuts: txOuts,
                        maxInputsPerTransaction: maxInputsPerTransaction),
                    file: file, line: line)
                if let expectedTotalFee = expectedTotalFee {
                    XCTAssertEqual(totalFee, expectedTotalFee, "Fee != expected fee",
                        file: file, line: line)
                }
            }()
        }
    }

    func testEstimateTotalFeeThrowsInsufficientTxOuts() {
        let sut = DefaultTxOutSelectionStrategy()
        var testCases: [TestCase3] = []
        testCases.append(contentsOf: insufficientFundsTestCases)

        for (amount, feeLevel, txOuts, maxInputsPerTransaction, _, _, _, file, line) in
            testCases
        {
            _ = try? {
                let error = try XCTUnwrapFailure(
                    sut.estimateTotalFee(
                        toSendAmount: Amount(mob: amount),
                        feeStrategy: feeLevel.defaultFeeStrategy,
                        txOuts: txOuts,
                        maxInputsPerTransaction: maxInputsPerTransaction),
                    file: file, line: line)
                if case .insufficientTxOuts = error {
                } else {
                    XCTFail("error not .insufficientTxOuts: \(error)", file: file, line: line)
                }
            }()
        }
    }

    func testSelectTransactionInputsWithFeeLevel() {
        let sut = DefaultTxOutSelectionStrategy()
        var testCases: [TestCase3] = []
        testCases.append(contentsOf: nonDefragTestCases)

        for (amount, feeLevel, txOuts, maxInputsPerTransaction, _, expectedTotalFee, _,
             file, line) in testCases
        {
            _ = try? {
                let (selectedIds, fee) = try XCTUnwrapSuccess(
                    sut.selectTransactionInputs(
                        amount: Amount(mob: amount),
                        feeStrategy: feeLevel.defaultFeeStrategy,
                        fromTxOuts: txOuts,
                        maxInputs: maxInputsPerTransaction),
                    file: file, line: line)
                checkSelectionIds(selectedIds: selectedIds, minTotalOutput: [amount, minFee],
                    txOuts: txOuts, maxInputs: maxInputsPerTransaction, file: file, line: line)
                if let expectedTotalFee = expectedTotalFee {
                    XCTAssertEqual(fee, expectedTotalFee, "Fee != expected fee",
                        file: file, line: line)
                }
            }()
        }
    }

    func testSelectTransactionInputsWithFeeLevelThrowsDefragRequired() {
        let sut = DefaultTxOutSelectionStrategy()
        var testCases: [TestCase3] = []
        testCases.append(contentsOf: defragTestCases)

        for (amount, feeLevel, txOuts, maxInputsPerTransaction, _, _, _, file, line) in
            testCases
        {
            _ = try? {
                let error = try XCTUnwrapFailure(
                    sut.selectTransactionInputs(
                        amount: Amount(mob: amount),
                        feeStrategy: feeLevel.defaultFeeStrategy,
                        fromTxOuts: txOuts,
                        maxInputs: maxInputsPerTransaction),
                    file: file, line: line)
                if case .defragmentationRequired = error {
                } else {
                    XCTFail("error not .defragmentationRequired: \(error)", file: file, line: line)
                }
            }()
        }
    }

    func testSelectTransactionInputsWithFeeLevelThrowsInsufficientTxOuts() {
        let sut = DefaultTxOutSelectionStrategy()
        var testCases: [TestCase3] = []
        testCases.append(contentsOf: insufficientFundsTestCases)

        for (amount, feeLevel, txOuts, maxInputsPerTransaction, _, _, _, file, line) in
            testCases
        {
            _ = try? {
                let error = try XCTUnwrapFailure(
                    sut.selectTransactionInputs(
                        amount: Amount(mob: amount),
                        feeStrategy: feeLevel.defaultFeeStrategy,
                        fromTxOuts: txOuts,
                        maxInputs: maxInputsPerTransaction),
                    file: file, line: line)
                if case .insufficientTxOuts = error {
                } else {
                    XCTFail("error not .insufficientTxOuts: \(error)", file: file, line: line)
                }
            }()
        }
    }

    func testSelectInputsForDefragTransactions() {
        let sut = DefaultTxOutSelectionStrategy()
        let testCases: [TestCase4] = []

        for (amount, feeLevel, txOuts, maxInputsPerTransaction, expectedResults, file, line) in
            testCases
        {
            _ = try? {
                let defragTxsInputs = try XCTUnwrapSuccess(
                    sut.selectInputsForDefragTransactions(
                        toSendAmount: Amount(mob: amount),
                        feeStrategy: feeLevel.defaultFeeStrategy,
                        fromTxOuts: txOuts,
                        maxInputsPerTransaction: maxInputsPerTransaction),
                    file: file, line: line)
                for (selectedIds, totalFee) in defragTxsInputs {
                    checkSelectionIds(selectedIds: selectedIds, minTotalOutput: [totalFee],
                        txOuts: txOuts, maxInputs: maxInputsPerTransaction, file: file, line: line)
                }
                if let expectedResults = expectedResults {
                    XCTAssertEqual(defragTxsInputs.count, expectedResults.count)
                    for ((selectedIds, totalFee), (expectedIds, expectedFee)) in
                        zip(defragTxsInputs, expectedResults)
                    {
                        XCTAssertEqual(Set(selectedIds), Set(expectedIds), file: file, line: line)
                        XCTAssertEqual(totalFee, expectedFee, "Fee != expected fee",
                            file: file, line: line)
                    }
                }
            }()
        }
    }

    func testSelectInputsForDefragTransactionsThrowsInsufficientTxOuts() {
        let sut = DefaultTxOutSelectionStrategy()
        var testCases: [TestCase3] = []
        testCases.append(contentsOf: insufficientFundsTestCases)

        for (amount, feeLevel, txOuts, maxInputsPerTransaction, _, _, _, file, line) in
            testCases
        {
            _ = try? {
                let error = try XCTUnwrapFailure(
                    sut.selectInputsForDefragTransactions(
                        toSendAmount: Amount(mob: amount),
                        feeStrategy: feeLevel.defaultFeeStrategy,
                        fromTxOuts: txOuts,
                        maxInputsPerTransaction: maxInputsPerTransaction),
                    file: file, line: line)
                if case .insufficientTxOuts = error {
                } else {
                    XCTFail("error not .insufficientTxOuts: \(error)", file: file, line: line)
                }
            }()
        }
    }

    func testNumDefragTransactions() {
        let sut = DefaultTxOutSelectionStrategy()
        let f = { sut.numDefragTransactions(numSelected: $0, maxInputsPerTransaction: $1) }
        XCTAssertEqual(f(1, 16), 0)
        XCTAssertEqual(f(16, 16), 0)
        XCTAssertEqual(f(17, 16), 1)
        XCTAssertEqual(f(31, 16), 1)
        XCTAssertEqual(f(32, 16), 2)
        XCTAssertEqual(f(92, 16), 6)
    }

}

extension DefaultTxOutSelectionStrategyTests {
    func checkSelectionIds(
        selectedIds: [Int],
        minTotalOutput: [UInt64],
        txOuts: [SelectionTxOut],
        maxInputs: Int,
        file: StaticString,
        line: UInt
    ) {
        XCTAssertEqual(selectedIds.count, Set(selectedIds).count,
            "Contains duplicate ids. Selected ids: \(selectedIds)", file: file, line: line)
        XCTAssertLessThanOrEqual(selectedIds.count, maxInputs,
            "Num selected inputs > max inputs", file: file, line: line)
        XCTAssert(selectedIds.allSatisfy { txOuts.indices.contains($0) },
            "Contains invalid ids: \(selectedIds.filter { !txOuts.indices.contains($0) })",
            file: file, line: line)
        if selectedIds.allSatisfy({ txOuts.indices.contains($0) }) {
            let selectedTxOuts = txOuts[selectedIds]
            let txOutValues = selectedTxOuts.map { $0.value }
            XCTAssert(
                UInt64.safeCompare(
                    sumOfValues: txOutValues,
                    isGreaterThanOrEqualToSumOfValues: minTotalOutput),
                "Sum value of selected TxOuts < than amount + fee. Selected TxOuts: " +
                    "\(selectedTxOuts)",
                file: file, line: line)
            XCTAssert(
                UInt64.safeCompare(
                    sumOfValues: txOutValues,
                    isLessThanOrEqualToSumOfValues: minTotalOutput + [UInt64.max]),
                "Remaining change amount > UInt64.max. Selected values: \(selectedTxOuts)",
                file: file, line: line)
            XCTAssert(txOutValues.allSatisfy { $0 > 0 },
                "Selected TxOuts with 0 value: \(selectedTxOuts.filter { $0.value == 0 })",
                file: file, line: line)
        }
    }
}

private typealias TestCase1 = (
    amount: UInt64,
    fee: UInt64,
    txOuts: [SelectionTxOut],
    maxInputs: Int,
    expectedIds: [Int]?,
    file: StaticString,
    line: UInt
)

private func t1(
    _ amount: UInt64,
    _ fee: UInt64,
    _ txOuts: [SelectionTxOut],
    maxInputs: Int = McConstants.MAX_INPUTS,
    _ expectedIds: [Int]? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase1 {
    (amount, fee, txOuts, maxInputs, expectedIds, file, line)
}

private typealias TestCase2 = (
    feeLevel: FeeLevel,
    txOuts: [SelectionTxOut],
    maxInputsPerTransaction: Int,
    expectedAmountTransferable: UInt64?,
    file: StaticString,
    line: UInt
)

private func t2(
    _ txOuts: [SelectionTxOut],
    maxInputsPerTransaction: Int = McConstants.MAX_INPUTS,
    expectedAmountTransferable: UInt64? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase2 {
    (.minimum, txOuts, maxInputsPerTransaction, expectedAmountTransferable, file, line)
}

private func t2(
    _ feeLevel: FeeLevel,
    _ txOuts: [SelectionTxOut],
    maxInputsPerTransaction: Int = McConstants.MAX_INPUTS,
    expectedAmountTransferable: UInt64? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase2 {
    (feeLevel, txOuts, maxInputsPerTransaction, expectedAmountTransferable, file, line)
}

private typealias TestCase3 = (
    amount: UInt64,
    feeLevel: FeeLevel,
    txOuts: [SelectionTxOut],
    maxInputsPerTransaction: Int,
    expectedAmountTransferable: UInt64?,
    expectedTotalFee: UInt64?,
    expectedIds: [Int]?,
    file: StaticString,
    line: UInt
)

private func t3(
    _ amount: UInt64,
    _ txOuts: [SelectionTxOut],
    maxInputsPerTransaction: Int = McConstants.MAX_INPUTS,
    expectedAmountTransferable: UInt64? = nil,
    expectedTotalFee: UInt64? = nil,
    _ expectedIds: [Int]? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase3 {
    (amount, .minimum, txOuts, maxInputsPerTransaction, expectedAmountTransferable,
     expectedTotalFee, expectedIds, file, line)
}

private func t3(
    _ amount: UInt64,
    _ feeLevel: FeeLevel,
    _ txOuts: [SelectionTxOut],
    maxInputsPerTransaction: Int = McConstants.MAX_INPUTS,
    expectedAmountTransferable: UInt64? = nil,
    expectedTotalFee: UInt64? = nil,
    _ expectedIds: [Int]? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase3 {
    (amount, feeLevel, txOuts, maxInputsPerTransaction, expectedAmountTransferable,
     expectedTotalFee, expectedIds, file, line)
}

private typealias TestCase4 = (
    amount: UInt64,
    feeLevel: FeeLevel,
    txOuts: [SelectionTxOut],
    maxInputsPerTransaction: Int,
    expected: [(inputIds: [Int], fee: UInt64)]?,
    file: StaticString,
    line: UInt
)

private func t4(
    _ amount: UInt64,
    _ txOuts: [SelectionTxOut],
    maxInputsPerTransaction: Int = McConstants.MAX_INPUTS,
    _ expected: [(inputIds: [Int], fee: UInt64)]? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase4 {
    (amount, .minimum, txOuts, maxInputsPerTransaction, expected, file, line)
}

private func t4(
    _ amount: UInt64,
    _ feeLevel: FeeLevel,
    _ txOuts: [SelectionTxOut],
    maxInputsPerTransaction: Int = McConstants.MAX_INPUTS,
    _ expected: [(inputIds: [Int], fee: UInt64)]? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase4 {
    (amount, feeLevel, txOuts, maxInputsPerTransaction, expected, file, line)
}

extension SelectionTxOut {
    init(value: UInt64) {
        self.init(value: value, blockIndex: 0)
    }
}
