//
//  Copyright (c) 2020-2026 MobileCoin. All rights reserved.
//

// swiftlint:disable prefixed_toplevel_constant

import Foundation

public enum MobileCoinLogging {
    // Both knobs are meant to be set once at startup, before any SDK call.
    // Only `logSensitiveData` enforces that, by trapping on a second write.
    // `logLevel` takes any number of writes and holds no lock, so setting it
    // while the SDK is running is a data race.
    nonisolated(unsafe) public static var logSensitiveData = false {
        willSet {
            guard logSensitiveDataInternal.set(newValue) else {
                logger.preconditionFailure(
                    "logSensitiveData can only be set prior to using the MobileCoin SDK.")
            }
        }
    }

    /// Minimum level the SDK prints to stdout.
    nonisolated(unsafe) public static var logLevel = Level.info

    public enum Level: Int, Comparable {
        case trace
        case debug
        case info
        case notice
        case warning
        case error
        case critical

        public static func < (lhs: Level, rhs: Level) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

internal let logger = Logger(label: "com.mobilecoin")

// The value of `logSensitiveDataInternal` gets locked in place upon first read.
private let logSensitiveDataInternal = ImmutableOnceReadLock(false)

internal struct Logger {
    let label: String

    func trace(
        _ message: @autoclosure () -> String,
        sensitive: Bool = false,
        logFunction: Bool = true,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            .trace,
            message(),
            sensitive: sensitive,
            logFunction: logFunction,
            file: file,
            function: function,
            line: line)
    }

    func debug(
        _ message: @autoclosure () -> String,
        sensitive: Bool = false,
        logFunction: Bool = true,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            .debug,
            message(),
            sensitive: sensitive,
            logFunction: logFunction,
            file: file,
            function: function,
            line: line)
    }

    func info(
        _ message: @autoclosure () -> String,
        sensitive: Bool = false,
        logFunction: Bool = true,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            .info,
            message(),
            sensitive: sensitive,
            logFunction: logFunction,
            file: file,
            function: function,
            line: line)
    }

    func notice(
        _ message: @autoclosure () -> String,
        sensitive: Bool = false,
        logFunction: Bool = true,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            .notice,
            message(),
            sensitive: sensitive,
            logFunction: logFunction,
            file: file,
            function: function,
            line: line)
    }

    func warning(
        _ message: @autoclosure () -> String,
        sensitive: Bool = false,
        logFunction: Bool = true,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            .warning,
            message(),
            sensitive: sensitive,
            logFunction: logFunction,
            file: file,
            function: function,
            line: line)
    }

    func error(
        _ message: @autoclosure () -> String,
        sensitive: Bool = false,
        logFunction: Bool = true,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            .error,
            message(),
            sensitive: sensitive,
            logFunction: logFunction,
            file: file,
            function: function,
            line: line)
    }

    func critical(
        _ message: @autoclosure () -> String,
        sensitive: Bool = false,
        logFunction: Bool = true,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            .critical,
            message(),
            sensitive: sensitive,
            logFunction: logFunction,
            file: file,
            function: function,
            line: line)
    }

    func log(
        _ level: MobileCoinLogging.Level,
        _ message: @autoclosure () -> String,
        sensitive: Bool = false,
        logFunction: Bool = true,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        guard level >= MobileCoinLogging.logLevel else { return }
        guard !sensitive || logSensitiveDataInternal.get() else { return }

        var message = message()
        if logFunction {
            let filename = URL(fileURLWithPath: file, isDirectory: false).lastPathComponent
            message = "\(filename):\(line):\(function) - \(message)"
        }
        print("\(Self.timestampFormatter.string(from: Date())) \(level) \(label) : \(message)")
    }

    // ISO8601DateFormatter is not Sendable, but formatting is thread safe and
    // this instance is never reconfigured after it is built.
    nonisolated(unsafe) private static let timestampFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

extension Logger {
    func assert(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        if condition() {
            assertionFailure(message(), file: file, function: function, line: line)
        }
    }

    func precondition(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        if condition() {
            preconditionFailure(message(), file: file, function: function, line: line)
        }
    }

    func assertionFailure(
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        let message = message()
        error("\(message)", file: "\(file)", function: function, line: line)
        Swift.assertionFailure(message, file: file, line: line)
    }

    func preconditionFailure(
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        function: String = #function,
        line: UInt = #line
    ) -> Never {
        let message = message()
        critical("\(message)", file: "\(file)", function: function, line: line)
        return Swift.preconditionFailure(message, file: file, line: line)
    }

    func fatalError(
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        function: String = #function,
        line: UInt = #line
    ) -> Never {
        let message = message()
        critical("\(message)", file: "\(file)", function: function, line: line)
        return Swift.fatalError(message, file: file, line: line)
    }
}

extension DefaultStringInterpolation {
    mutating func appendInterpolation<T>(redacting value: T)
        where T: CustomStringConvertible & TextOutputStreamable
    {
        if logSensitiveDataInternal.get() {
            appendInterpolation(value)
        } else {
            appendInterpolation("<redacted>")
        }
    }

    mutating func appendInterpolation<T: TextOutputStreamable>(redacting value: T) {
        if logSensitiveDataInternal.get() {
            appendInterpolation(value)
        } else {
            appendInterpolation("<redacted>")
        }
    }

    mutating func appendInterpolation<T: CustomStringConvertible>(redacting value: T) {
        if logSensitiveDataInternal.get() {
            appendInterpolation(value)
        } else {
            appendInterpolation("<redacted>")
        }
    }

    mutating func appendInterpolation<T>(redacting value: T) {
        if logSensitiveDataInternal.get() {
            appendInterpolation(value)
        } else {
            appendInterpolation("<redacted>")
        }
    }

    mutating func appendInterpolation(redacting value: Any.Type) {
        if logSensitiveDataInternal.get() {
            appendInterpolation(value)
        } else {
            appendInterpolation("<redacted>")
        }
    }

    mutating func appendInterpolation<T: CustomRedactingStringConvertible>(redacting value: T) {
        appendInterpolation(value.redactingDescription)
    }
}
