//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

private class Container {
    var counter = 0
}

class SerialCallbackLockTests: XCTestCase {

    func testInit() {
        _ = SerialCallbackLock(0, targetQueue: nil)
    }

    func testWorks() {
        let lock = SerialCallbackLock(Container(), targetQueue: nil)

        let expect = expectation(description: "SerialCallbackLock async access")
        let group = DispatchGroup()

        group.enter()
        lock.accessAsync { obj, callback in
            obj.counter = 10
            callback()
            group.leave()
        }

        group.enter()
        lock.accessAsync { obj, callback in
            XCTAssertEqual(obj.counter, 10)
            callback()
            group.leave()
        }

        group.enter()
        lock.accessAsync { obj, callback in
            obj.counter = 20
            callback()
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(lock.accessWithoutLocking.counter, 20)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testNestingWorks() {
        let lock = SerialCallbackLock(Container(), targetQueue: nil)

        let expect = expectation(description: "SerialCallbackLock async access")
        let group = DispatchGroup()

        group.enter()
        lock.accessAsync { obj, callback in
            obj.counter = 10
            callback()
            group.leave()
        }

        group.enter()
        lock.accessAsync { obj, callback in
            group.enter()
            lock.accessAsync { obj, callback in
                XCTAssertEqual(obj.counter, 20)
                obj.counter = 30
                callback()
                group.leave()
            }

            obj.counter = 20
            callback()
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(lock.accessWithoutLocking.counter, 30)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testMultipleAccess() {
        let lock = SerialCallbackLock(Container(), targetQueue: nil)

        let expect = expectation(description: "SerialCallbackLock async access")
        let group = DispatchGroup()
        for _ in (0..<100) {
            group.enter()
            lock.accessAsync { obj, callback in
                obj.counter += 1
                callback()
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
        let lock = SerialCallbackLock(Container(), targetQueue: nil)

        let expect = expectation(description: "SerialCallbackLock async access")
        let group = DispatchGroup()
        for _ in (0..<100) {
            group.enter()
            DispatchQueue.global().async {
                lock.accessAsync { obj, callback in
                    obj.counter += 1
                    callback()
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
