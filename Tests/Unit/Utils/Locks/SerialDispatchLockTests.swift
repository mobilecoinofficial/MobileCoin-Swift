//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

private class Container {
    var counter = 0
}

class SerialDispatchLockTests: XCTestCase {

    func testInit() {
        _ = SerialDispatchLock(0, targetQueue: nil)
    }

    func testWorks() {
        let lock = SerialDispatchLock(Container(), targetQueue: nil)

        let expect = expectation(description: "SerialDispatchLock async access")
        lock.accessAsync {
            $0.counter = 10
            lock.accessAsync {
                XCTAssertEqual($0.counter, 10)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 2)
    }

    func testConsecutiveAccessWorks() {
        let lock = SerialDispatchLock(Container(), targetQueue: nil)

        let expect = expectation(description: "SerialDispatchLock async access")
        let group = DispatchGroup()

        group.enter()
        lock.accessAsync {
            $0.counter = 10
            group.leave()
        }

        group.enter()
        lock.accessAsync {
            XCTAssertEqual($0.counter, 10)
            group.leave()
        }

        group.enter()
        lock.accessAsync {
            $0.counter = 20
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(lock.accessWithoutLocking.counter, 20)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testNestingWorks() {
        let lock = SerialDispatchLock(Container(), targetQueue: nil)

        let expect = expectation(description: "SerialDispatchLock async access")
        let group = DispatchGroup()

        group.enter()
        lock.accessAsync {
            $0.counter = 10
            group.leave()
        }

        group.enter()
        lock.accessAsync {
            group.enter()
            lock.accessAsync {
                XCTAssertEqual($0.counter, 20)
                $0.counter = 30
                group.leave()
            }

            $0.counter = 20
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(lock.accessWithoutLocking.counter, 30)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testMultipleAccess() {
        let lock = SerialDispatchLock(Container(), targetQueue: nil)

        let expect = expectation(description: "SerialDispatchLock async access")
        let group = DispatchGroup()
        for _ in (0..<100) {
            group.enter()
            lock.accessAsync {
                $0.counter += 1
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(lock.accessWithoutLocking.counter, 100)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testConcurrentAccess() {
        let lock = SerialDispatchLock(Container(), targetQueue: nil)

        let expect = expectation(description: "SerialDispatchLock async access")
        let group = DispatchGroup()
        for _ in (0..<100) {
            group.enter()
            DispatchQueue.global().async {
                lock.accessAsync {
                    $0.counter += 1
                    group.leave()
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(lock.accessWithoutLocking.counter, 100)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

}
