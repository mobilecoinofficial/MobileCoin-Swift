# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Removed

- `Sources/GRPC` and `Tests/ProtocolSpecific/Grpc`. No product or subspec
  compiled either tree.
- The Mistyswap integration tests. Every case built an `XCTSkip` value without
  throwing it, so every case ran against the gRPC transport. The suite carries
  no HTTP variant.
- `TransportProtocol.grpc`, the last public name for a transport the package
  cannot build. `TransportProtocol.http` is the only case left.
- `ConnectionOptionWrapper`, the `Sources/Common/Network/ProtocolSpecific` tree,
  and the eight `Empty*` service stand-ins the HTTP factory makes unreachable.

The first two removals leave public API untouched. Removing
`TransportProtocol.grpc` breaks a caller that names it.

## [6.1.0] - 2026-09-01

### Changed

- The SwiftPM `MobileCoinCore` product is now HTTP only. It consumes
  `LibMobileCoinCoreHTTP` and no longer compiles `Sources/GRPC`. This matches
  the CocoaPods chain, whose only subspec has been `CoreHTTP` for some time.
- Every target in the package compiles in the Swift 6 language mode. No target
  declares a language mode of its own. The test targets reach it by asserting
  `@unchecked Sendable` on their `XCTestCase` subclasses rather than by
  restructuring how async tests capture `self`. XCTest gives each test method
  its own instance, so the assertion holds for the suite as written.
- The two routes now have different toolchain floors. SwiftPM needs Swift 6.1,
  Xcode 16.3 or newer, because the manifest declares
  `swift-tools-version:6.1` and SwiftPM rejects it outright below that.
  CocoaPods needs Swift 5.10, Xcode 15.3 or newer, because
  `MobileCoinLogging` and the shared test mocks use `nonisolated(unsafe)` and
  no earlier compiler parses it. The podspec's `swift_version` is a language
  mode and does not express either floor.
- `DefaultHttpRequester` is `final` and no longer conforms to
  `URLSessionDelegate` or `URLSessionTaskDelegate`. Certificate pinning moved
  to an internal delegate holding both trust roots behind one lock. Subclassing
  the requester, calling its `urlSession(_:didReceive:completionHandler:)`
  methods, or passing it where a `URLSessionDelegate` is expected, no longer
  compiles.
- `DefaultHttpRequester` invalidates its session on `deinit` with
  `finishTasksAndInvalidate`, so a requester no longer leaks its delegate. The
  session stays alive until its in-flight tasks drain, so a consumer that
  releases a requester mid-request still gets that request's completion
  callback after the requester is gone.
- 51 types under `Sources` conform to `Sendable`, 36 of them public. A consumer
  that wrote a retroactive conformance as a Swift 6 workaround now gets a
  duplicate-conformance warning and should drop theirs.
- `withTimeout(seconds:block:)` constrains its return type to `Sendable`.
- `TokenId.MOB`, `TokenId.MOBUSD` and `TokenId.TestToken` are `let` rather than
  `var`.
- The podspec bounds SwiftProtobuf at `>= 1.36, < 1.38` and the package floor is
  1.36.1. 1.38 emits `nonisolated extension`, which pre-Swift-6.1 toolchains
  reject.
- The iOS deployment target is now 13.0. LibMobileCoin 6.1.0 declares that
  floor, and CocoaPods refuses a dependency whose deployment target is above
  the dependent's.
- `LibMobileCoin/CoreHTTP` now resolves at 6.1.0 or newer.

### Removed

- `TransportProtocol.grpc` is no longer usable from SwiftPM. Calls made with it
  now fail with a `connectionFailure` instead of never calling back. CocoaPods
  consumers are unaffected; the pod already had no grpc subspec.
- `TransportProtocol.supportedProtocols` returns `[.http]` rather than
  `[.grpc, .http]` for SwiftPM consumers.
- The `Vendor/libmobilecoin` submodule. SwiftPM takes libmobilecoin from its
  checksummed release asset and CocoaPods takes it from the tagged repository,
  so a build needs neither a submodule checkout nor git-lfs.

## [6.0.7] - 2026-08-31

### Added

- `MobileCoinClient.txOutContexts(to:rngSeed:)` derives the payload and change
  TxOut public keys a transaction will carry, from an RNG seed alone, without
  building or submitting one. Send with
  `prepareTransaction(rng: MobileCoinChaCha20Rng(rngSeed: seed))` on the same
  seed and the transaction carries the keys it reported.

## [4.0.1] - 2023-03-02

### Added

- Public access to Ristretto structs with a wrapper

## [4.0.0] - 2023-02-07

### Added

- Signed Contingent Inputs MCIP#0031

## [4.0.0-pre9] - 2023-02-01

### Changed

- Fix incorrect defragmentation tx out selection.

### Added

- Integration test for defragmentation and fragmentation

## [4.0.0-pre8] - 2023-02-01

### Changed

- Use newer libmobilecoin commit that has Xcode 13/14 fixes

## [4.0.0-pre7] - 2023-01-18

### Changed

- Access level of DefaultCyrptoBox

## [4.0.0-pre6] - 2023-01-10

### Changed

- Update LICENSE from GPLv3 to Apace 2

## [4.0.0-pre5] - 2022-12-15

### Changed

- Added more fields to Memo codable paths

## [4.0.0-pre4] - 2022-12-13

### Added

- Encodable conformance to RecoveredMemo structs

## [4.0.0-pre3] - 2022-12-11

### Added

- Un-authenticated sender memo access

## [4.0.0-pre2] - 2022-12-08

### Added

- Masked Amount V1 & V2 Changes

## [4.0.0-pre1] - 2022-11-07

### Added

- Add Payment Intent RTH Memos

## [4.0.0-pre0] - 2022-11-07

### Changed

- Expose address hash publicly

## [1.3.0-pre3] - 2022-10-05

### Added

- Add TokenID to PaymentRequest

## [1.3.0-pre2] - 2022-09-26

### Added

- Transaction Idempotence Compatibility Sync-up with Android SDK

## [1.3.0-pre1] - 2022-09-19

### Changed

- Transaction Idempotence Support Simplified

## [2.0.2] - 2022-08-29

### Changed

- `@available` Minimum version for async APIs

## [2.0.1] - 2022-08-29

### Changed

- Access modifier for ChaCha RNG

## [2.0.0] - 2022-08-29

### Added

- Transaction Idempotence Support
- TransactionStatusChecker for simpler and quicker transactions tatus
- Async/Await API wrappers for MobileCoinClient
- New `submitTransaction` method that always returns the conensus block count

## [1.2.2-pre2] - 2022-07-13

### Added

- New testNet enclave measurements

## [1.2.2-pre1] - 2022-07-13

### Added

- New method for `submitTransaction` that always returns the conensus block count

### Changed

- Old method for `submitTransaction` deprecated

## [1.2.2-pre0] - 2022-06-24

### Changed

- SwiftNIO dependency update

## [1.2.1] - 2022-06-09

### Added

- FFIs for root_entropy, shared_secret
- v1.2.1 mobilecoin libraries

## [1.2.0] - 2022-06-03

### Added
- Support for multiple [token types](https://github.com/mobilecoinfoundation/mcips/blob/main/text/0025-confidential-token-ids.md)
- [Recoverable Transaction History (RTH)](https://github.com/mobilecoinfoundation/mcips/blob/main/text/0004-recoverable-transaction-history.md)

### Changed
- Change TxOuts are now sent to a dedicated [change subaddress](https://github.com/mobilecoinfoundation/mcips/blob/main/text/0036-reserved-subaddresses.md)
- Internal block info cache invalidated on submit transaction error, causing fees and block version to be re-fetched
- Deprecate older APIs that do not support Token IDs

### Fixes
- FogSyncException will be thrown if Fog View and Ledger are out of sync with each other or Consensus.
  This signifies that balances may temporarily be out of date or incorrect.

## [1.2.0-pre11] - 2022-02-03

### Changed

- Version lock gRPC and SwiftNIO for robustness with idle connections

### Added

- Internal Load Balancer, default connection timeout for gRPC

## [1.2.0-pre10] - 2022-02-03

### Changed

- Use build-artifacts from CI/CD

## [1.2.0-pre9] - 2022-02-03

### Added 

- crc32 checksum comparison for reconstructed commitment data

### Changed

- Simplified Publicly Exposed Error's conformers.

## [1.2.0-pre8] - 2022-01-31

### Added

- Add Reference Implementation of cert-pinning for HTTPS 
- Add Helper functions for working with "certificate" data

## [1.2.0-pre7] - 2022-01-07

### Added

- fog report short URL verification
- CI/CD 

## [1.2.0-pre6] - 2022-01-06

### Added

- HTTP Only Build Target

## [1.2.0-pre5] - 2021-12-1

### Added

- Process TxOuts on a user's default change subaddress
- Add bip39 to TransferPayload & Printable

### Changed

- Add seperate HTTP & GRPC Test schemes

## [1.2.0-pre2] - 2021-10-27

### Added

- Support for Apple's Bitcode. Reduces compressed "downloadable" size by 25% (#80)

### Changed

- Upgraded LibMobileCoin to v1.2.0-pre3 (#80)
- Updated Trust Root Certificate (#78)

## [1.2.0-pre0] - 2021-09-17

### Added

- HTTP Interface to API for Network Robustness (#73)
- Apple Silicon M1 & Mac Catalyst Support (#73)

### Changed

- Upgraded LibMobileCoin & Fog to v1.2.0-pre1 (#73)

## [1.1.0] - 2021-06-10

### Added

- Minimum transaction fee caching. (#38)

### Changed

- Upgraded LibMobileCoin to v1.1.0. (#39)

## [1.1.0-pre2] - 2021-05-10

### Added

- Dynamic minimum transaction fee. (#29)

### Changed

- Upgraded LibMobileCoin to v1.1.0-pre2. (#27)

## [1.0.0] - 2021-04-05

## 1.0.0-rc1 - 2021-03-15

[1.1.0]: https://github.com/mobilecoinofficial/MobileCoin-Swift/compare/1.1.0-pre2...1.1.0
[1.1.0-pre2]: https://github.com/mobilecoinofficial/MobileCoin-Swift/compare/1.0.0...1.1.0-pre2
[1.0.0]: https://github.com/mobilecoinofficial/MobileCoin-Swift/compare/1.0.0-rc1...1.0.0

