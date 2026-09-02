//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

// These boxes exist to be mutated from several queues at once. That is what the
// queue under test is meant to serialize, so the checking is the test's job.
private class Container: @unchecked Sendable {
    var counter: Int = 0
}

private class Container2: @unchecked Sendable {
    var counter1: Int = 0
    var counter2: Int = 0
}

class SerialCallbackQueueTests: XCTestCase, @unchecked Sendable {

    func testInit() {
        _ = SerialCallbackQueue(targetQueue: nil)
    }

    func testWorks() {
        let obj = Container()
        let queue = SerialCallbackQueue(targetQueue: nil)

        let expect = expectation(description: "SerialCallbackQueue async access")
        let group = DispatchGroup()

        group.enter()
        queue.append { callback in
            obj.counter = 10
            // The queue declares its continuation without `@Sendable`. It runs
            // one task at a time, so only one of these hops is ever live.
            nonisolated(unsafe) let callback = callback
            DispatchQueue.main.async {
                XCTAssertEqual(obj.counter, 10)
                obj.counter = 20

                callback()
                group.leave()
            }
        }

        group.enter()
        queue.append { callback in
            XCTAssertEqual(obj.counter, 20)
            obj.counter = 30
            nonisolated(unsafe) let callback = callback
            DispatchQueue.main.async {
                XCTAssertEqual(obj.counter, 30)
                obj.counter = 40

                callback()
                group.leave()
            }
        }

        group.enter()
        queue.append { callback in
            XCTAssertEqual(obj.counter, 40)
            obj.counter = 50
            callback()
            group.leave()
        }

        group.enter()
        queue.append { callback in
            XCTAssertEqual(obj.counter, 50)
            obj.counter = 60
            callback()
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(obj.counter, 60)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testMultipleAccess() {
        let obj = Container()
        let queue = SerialCallbackQueue(targetQueue: nil)

        let expect = expectation(description: "SerialCallbackQueue async access")
        let group = DispatchGroup()
        for i in (0..<100) {
            group.enter()
            queue.append { callback in
                XCTAssertEqual(obj.counter, i)
                obj.counter += 1
                callback()
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(obj.counter, 100)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testSequentialAccess() {
        let obj = Container2()
        let queue = SerialCallbackQueue(targetQueue: nil)

        let expect = expectation(description: "SerialCallbackQueue async access")
        let group = DispatchGroup()
        for i in (0..<100) {
            group.enter()
            queue.append { callback in
                XCTAssertEqual(obj.counter1, 2 * i)
                obj.counter1 += 1

                queue.append { callback in
                    XCTAssertEqual(obj.counter2, 4 * i)
                    obj.counter2 += 1

                    DispatchQueue.global().async {
                        XCTAssertEqual(obj.counter2, 4 * i + 1)
                        obj.counter2 += 1

                        callback()
                    }
                }

                queue.append { callback in
                    XCTAssertEqual(obj.counter2, 4 * i + 2)
                    obj.counter2 += 1

                    DispatchQueue.global().async {
                        XCTAssertEqual(obj.counter2, 4 * i + 3)
                        obj.counter2 += 1

                        callback()
                        group.leave()
                    }
                }

                DispatchQueue.global().async {
                    XCTAssertEqual(obj.counter1, 2 * i + 1)
                    obj.counter1 += 1

                    callback()
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(obj.counter1, 200)
            XCTAssertEqual(obj.counter2, 400)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testConcurrentAccess() {
        let obj = Container2()
        let queue = SerialCallbackQueue(targetQueue: nil)

        let expect = expectation(description: "SerialCallbackQueue async access")
        let group = DispatchGroup()
        // The callbacks mutate this counter from several queues, so it lives
        // in a box rather than in the frame.
        let c = Container()
        for _ in (0..<100) {
            group.enter()
            DispatchQueue.global().async {
                queue.append { callback in
                    let val = obj.counter1
                    obj.counter1 += 1

                    queue.append { callback in
                        XCTAssertEqual(obj.counter2, 2 * c.counter)
                        c.counter += 1

                        let val2 = obj.counter2
                        obj.counter2 += 1

                        DispatchQueue.global().async {
                            XCTAssertEqual(obj.counter2, val2 + 1)
                            obj.counter2 += 1

                            callback()
                        }
                    }

                    DispatchQueue.global().async {
                        XCTAssertEqual(obj.counter1, val + 1)
                        obj.counter1 += 1

                        queue.append { callback in
                            XCTAssertEqual(obj.counter2, 2 * c.counter)
                            c.counter += 1

                            let val2 = obj.counter2
                            obj.counter2 += 1

                            DispatchQueue.global().async {
                                XCTAssertEqual(obj.counter2, val2 + 1)
                                obj.counter2 += 1

                                callback()
                                group.leave()
                            }
                        }

                        callback()
                    }
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            XCTAssertEqual(obj.counter1, 200)
            XCTAssertEqual(obj.counter2, 400)
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

}
