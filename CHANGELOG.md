# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
