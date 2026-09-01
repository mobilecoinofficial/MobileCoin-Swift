![MobileCoin logo](https://raw.githubusercontent.com/mobilecoinofficial/mobilecoin/master/img/mobilecoin_logo.png)

[![ci](https://github.com/mobilecoinofficial/MobileCoin-Swift/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/mobilecoinofficial/MobileCoin-Swift/actions/workflows/ci.yml) [![Documentation](https://img.shields.io/badge/docs-latest-blue)](https://mobilecoinofficial.github.io/MobileCoin-Swift/)

# MobileCoin Swift

MobileCoin is a privacy-preserving payments network designed for use on mobile devices.

# Sending your First Payment

* You must read and accept the [Terms of Use for MobileCoins and MobileCoin Wallets](./TERMS-OF-USE.md) to use MobileCoin Software.

### Note to Developers

* MobileCoin is a prototype. Expect substantial changes before the release.
* Please see [*CONTRIBUTING.md*](./CONTRIBUTING.md) for notes on contributing bug reports and code.

# `libmobilecoin` moved

A fresh `libmobilecoin` repository took over the name. Its history starts at v6.1.0, so every older commit hash resolves only in [`libmobilecoin-archive`](https://github.com/mobilecoinofficial/libmobilecoin-archive). The `Vendor/libmobilecoin` submodule points there until the CocoaPods migration removes it. An existing clone needs `git submodule sync --recursive` to pick up the new URL.

Both repositories carry a `v6.1.0` tag, and `libmobilecoin.git` served the archive's one before the rename. SwiftPM records the fingerprint it first resolved for a URL and refuses a different one. A machine that saw the archive's tag needs `~/.swiftpm/security/fingerprints/libmobilecoin-*.json` deleted once.

# Table of Contents
- [License](#license)
- [Cryptography Notice](#cryptography-notice)
- [Repository Structure](#repository-structure)
- [Build Instructions](#build-instructions)
- [Overview](#overview)
- [Support](#support)
- [Trademarks](#trademarks)

## License

MobileCoin is available under open-source licenses. Please read the [*LICENSE.md*](./LICENSE.md) and corresponding [*LICENSE*](./LICENSE).

## Cryptography Notice
This distribution includes cryptographic software. Your country may have restrictions on the use of encryption software.
Please check your country's laws before downloading or using this software.

## Repository Structure
|Directory |Description |
| :-- | :-- |
| [Docs](./docs) | Integration Guide. |
| [Example](./Example) | Example application. |
| [ExampleHTTP](./ExampleHTTP) | Example "HTTP Only" application. |
| [scripts](./scripts) | Scripts used by this repo. |
| [secrets](./secrets) | Secrets file for contributors, and their public keys. |
| [Sources](./Sources) | Sources for the MobileCoin Swift SDK. |
| [Tests](./Tests) | Tests. |
| [Vendor](./Vendor) | iOS Artifacts. |

## Build Instructions

The workspace can be built with `make`.

1. Initialize or update submodules

    ```
    git submodule update --init --recursive
    ```

1. Install Ruby 2.7.x

1. Install the gem bundler

    ```
    gem install bundler
    ```

1. Install pre-commit

    ```
    brew install pre-commit
    pre-commit install
    ```

1. Build the MobileCoin Swift SDK

    ```
    make
    ```

Note: To build libmobilecoin, run `make` in [libmobilecoin-ios-artifacts](./Vendor/libmobilecoin-ios-artifacts).

## Secrets

New contributors should follow the directions in the [Secrets' README.md](./secrets/README.md) to get access to the keys used in internal testing.

## Overview

MobileCoin is a payment network with no central authority. The fundamental goal of the network is to safely and
efficiently enable the exchange of value, represented as fractional ownership of the total value of the network.
Like most cryptocurrencies, MobileCoin maintains a permanent and immutable record of all successfully completed
payments in a blockchain data structure. Cryptography is used extensively to establish ownership, control transfers,
and to preserve cash-like privacy for users.

For more information about the cryptocurrency, see [MobileCoinFoundation/MobileCoin](https://github.com/mobilecoinfoundation/mobilecoin).

## Important Technical Documentation

A list of documents and resources that are useful for understanding how MobileCoin works.

- [MobileCoin Whitepapers](https://developers.mobilecoin.com/overview/read-the-whitepapers/)
- [Mechanics of MobileCoin](https://developers.mobilecoin.com/overview/read-the-whitepapers/mechanics)
  
> Pay particular attention to the discussion of Fog, as it is key mobilecoin’s ability to function well on mobile devices.

## Support

For troubleshooting help and other questions, please visit our [community forum](https://community.mobilecoin.foundation/).

You can also open a technical support ticket via [email](mailto://support@mobilecoin.com).

#### Trademarks

MobileCoin is a registered trademark of MobileCoin Inc.
