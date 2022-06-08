//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable function_body_length

@testable import MobileCoin
import XCTest

private class Container {
    var counter = 0
}

private class Container2 {
    var counter1 = 0
    var counter2 = 0
}

class ReadWriteDispatchLockTests: XCTestCase {

    func testInit() {
        _ = ReadWriteDispatchLock(0)
    }

    func testRead() {
        let container = Container()
        container.counter = 10
        let lock = ReadWriteDispatchLock(container)
        lock.readSync { XCTAssertEqual($0.counter, 10) }
    }

    func testWrite() {
        let lock = ReadWriteDispatchLock(Container())
        lock.writeSync { $0.counter = 10 }
        XCTAssertEqual(lock.accessWithoutLocking.counter, 10)
    }

    func testMultipleWrites() {
        let lock = ReadWriteDispatchLock(Container())
        for _ in (0..<100) {
            lock.writeSync { $0.counter += 1 }
        }
        XCTAssertEqual(lock.accessWithoutLocking.counter, 100)
    }

    func testConcurrentWrites() {
        let lock = ReadWriteDispatchLock(Container())

        let expect = expectation(description: "ReadWriteDispatchLock async access")
        let group = DispatchGroup()
        for _ in (0..<100) {
            group.enter()
            DispatchQueue.global().async {
                lock.writeSync { $0.counter += 1 }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(lock.accessWithoutLocking.counter, 100)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testConcurrentReadsAndWrites() {
        let lock = ReadWriteDispatchLock(Container2())

        let expect = expectation(description: "ReadWriteDispatchLock async access")
        let group = DispatchGroup()
        for _ in (0..<100) {
            group.enter()
            DispatchQueue.global().async {
                lock.readSync {
                    let counter1 = $0.counter1
                    let counter2 = $0.counter2
                    XCTAssertEqual(counter1, counter2)
                }
                group.leave()
            }

            group.enter()
            DispatchQueue.global().async {
                lock.readSync {
                    let counter2 = $0.counter2
                    let counter1 = $0.counter1
                    XCTAssertEqual(counter2, counter1)
                }
                group.leave()
            }

            group.enter()
            DispatchQueue.global().async {
                lock.writeSync {
                    $0.counter1 += 1
                    $0.counter2 += 1
                }
                group.leave()
            }

            group.enter()
            DispatchQueue.global().async {
                lock.writeSync {
                    $0.counter2 += 1
                    $0.counter1 += 1
                }
                group.leave()
            }

            group.enter()
            DispatchQueue.global().async {
                lock.readSync {
                    let counter1 = $0.counter1
                    let counter2 = $0.counter2
                    XCTAssertEqual(counter1, counter2)
                }
                group.leave()
            }

            group.enter()
            DispatchQueue.global().async {
                lock.readSync {
                    let counter2 = $0.counter2
                    let counter1 = $0.counter1
                    XCTAssertEqual(counter2, counter1)
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(lock.accessWithoutLocking.counter1, 200)
            XCTAssertEqual(lock.accessWithoutLocking.counter2, 200)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

}
