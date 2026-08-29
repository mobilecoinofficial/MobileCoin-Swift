//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

/// `ImmutableOnceReadLock` is a Dispatch-based lock that is mutable before being read and immutable
/// afterwards. This is useful in situations where you want to lock in a value and know that it
/// won't change once you start using it, but you still want to freely allow setting it before then.
extension ImmutableOnceReadLock: @unchecked Sendable where Value: Sendable { }

final class ImmutableOnceReadLock<Value> {
    private let inner: ReadWriteDispatchLock<Inner<Value>>

    init(_ value: Value) {
        self.inner = .init(Inner(value))
    }

    /// Gets the contained value and makes it immutable to further changes.
    func get() -> Value {
        // Every read goes through the lock. This used to cache into a `lazy var`,
        // which made concurrent first reads a race, because lazy initialization
        // carries no synchronization of its own.
        guard let value = inner.readSync({ $0.get() }) else {
            return inner.writeSync { $0.initializeIfNeededAndGet() }
        }
        return value
    }

    /// Sets the contained value if it hasn't been read yet, and returns whether the assignment took
    /// place or not.
    @discardableResult
    func set(_ value: Value) -> Bool {
        inner.writeSync { $0.set(value) }
    }
}

extension ImmutableOnceReadLock {
    private struct Inner<InnerValue> {
        private var value: InnerValue
        private var initialized = false

        init(_ value: InnerValue) {
            self.value = value
        }

        func get() -> InnerValue? {
            guard initialized else {
                return nil
            }
            return value
        }

        mutating func initializeIfNeededAndGet() -> InnerValue {
            if !initialized {
                initialized = true
            }
            return value
        }

        mutating func set(_ value: InnerValue) -> Bool {
            guard !initialized else {
                return false
            }

            initialized = true
            self.value = value

            return true
        }
    }
}
