//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable inclusive_language let_var_whitespace

@testable import MobileCoin
import NIOSSL
import XCTest

#if canImport(Keys)
import Keys
#endif

enum MobileCoinNetwork {
    /// External TestNet
    case test

    /// External staging network
    case alpha

    /// Internal mobile dev network
    case mobiledev

    /// Latest internal master
    case master

    // Ops dev networks
    case build
    case demo
    case diogenes
    case drakeley
    case eran
}

extension MobileCoinNetwork {
    var isTestNet: Bool { self == .test }

    var consensusRequiresCredentials: Bool { !isTestNet }
    var fogRequiresCredentials: Bool { !isTestNet }
    var isConsensusBehindLoadBalancer: Bool { !isTestNet }

    private var consensusSubdomain: String { isConsensusBehindLoadBalancer ? "consensus" : "node1" }

    var consensusUrl: String { "mc://\(consensusSubdomain).\(self).mobilecoin.com" }
    var fogUrl: String { "fog://fog.\(self).mobilecoin.com" }

    var fogReportUrl: String { "fog://fog.\(self).mobilecoin.com" }
    var fogReportId: String { "" }
    func fogAuthoritySpki() throws -> Data {
        try XCTUnwrap(Data(base64Encoded: fogAuthoritySpkiB64Encoded))
    }

    var attestationConfig: NetworkConfig.AttestationConfig {
        isTestNet ? .testNetMrSigner : .devMrSigner
    }

    func trustRootsBytes() throws -> Data { try XCTUnwrap(Data(base64Encoded: Self.trustRootsB64)) }
    private func trustRoots() throws -> [NIOSSLCertificate] {
        let bytes = try XCTUnwrap(Data(base64Encoded: Self.trustRootsB64))
        return [try NIOSSLCertificate(bytes: Array(bytes), format: .der)]
    }
    func consensusTrustRoots() throws -> [NIOSSLCertificate] { try trustRoots() }
    func fogTrustRoots() throws -> [NIOSSLCertificate] { try trustRoots() }

    private var consensusUsername: String { Self.devAuthUsername }
    private var consensusPassword: String { Self.devAuthPassword }
    var consensusCredentials: BasicCredentials
        { BasicCredentials(username: consensusUsername, password: consensusPassword) }

    private var fogUsername: String { Self.devAuthUsername }
    private var fogPassword: String { Self.devAuthPassword }
    var fogCredentials: BasicCredentials
        { BasicCredentials(username: fogUsername, password: fogPassword) }

    private var invalidCredUsername: String { "user1" }
    private var invalidCredPassword: String { "user1:1602033437:ffffffffffffffffffff" }
    var invalidCredentials: BasicCredentials
        { BasicCredentials(username: invalidCredUsername, password: invalidCredPassword) }

    var rootEntropies: [Data32] { isTestNet ? Self.testNetRootEntropies : Self.devRootEntropies }
}

extension MobileCoinNetwork {

#if canImport(Keys)
    static let devAuthUsername = MobileCoinKeys().mobilecoinDevAuthUsername
    static let devAuthPassword = MobileCoinKeys().mobilecoinDevAuthPassword
#else
    static let devAuthUsername = ""
    static let devAuthPassword = ""
#endif

    static let devRootEntropies = [
        // account key 0
        Data32([
            2, 154, 47, 57, 69, 168, 246, 187, 31, 181, 177, 26, 84, 40, 58, 64, 82, 109, 40, 35,
            89, 36, 57, 5, 241, 163, 13, 184, 42, 158, 89, 124,
        ])!,
        // account key 1
        Data32([
            235, 248, 189, 155, 66, 104, 44, 250, 214, 183, 186, 1, 207, 223, 8, 175, 44, 56, 144,
            124, 175, 51, 183, 218, 248, 136, 152, 109, 7, 181, 84, 156,
        ])!,
        // account key 2
        Data32([
            86, 38, 184, 6, 231, 115, 110, 86, 143, 103, 115, 30, 138, 38, 216, 229, 129, 195, 47,
            10, 175, 253, 198, 67, 251, 189, 171, 114, 161, 235, 87, 8,
        ])!,
        // account key 3
        Data32([
            114, 112, 34, 231, 208, 185, 252, 112, 117, 246, 59, 224, 40, 126, 182, 209, 39, 130,
            89, 86, 102, 77, 203, 73, 253, 88, 59, 238, 85, 130, 15, 200,
        ])!,
        // account key 4
        Data32([
            29, 186, 225, 89, 96, 98, 80, 144, 202, 70, 150, 149, 157, 150, 60, 120, 14, 200, 137,
            235, 152, 231, 77, 80, 71, 212, 32, 82, 69, 206, 81, 55,
        ])!,
        // account key 5
        Data32([
            79, 213, 120, 85, 72, 42, 9, 104, 143, 186, 253, 144, 137, 115, 37, 43, 155, 47, 60, 75,
            157, 110, 124, 55, 155, 101, 175, 167, 95, 235, 51, 66,
        ])!,
        // account key 6
        Data32([
            28, 126, 75, 230, 193, 96, 159, 197, 223, 166, 62, 106, 153, 87, 184, 180, 126, 12, 188,
            128, 238, 64, 134, 207, 195, 142, 37, 20, 117, 39, 246, 63,
        ])!,
        // account key 7
        Data32([
            145, 231, 241, 91, 240, 144, 214, 193, 230, 37, 152, 119, 69, 3, 60, 14, 43, 117, 90,
            203, 54, 133, 25, 210, 33, 104, 135, 216, 57, 67, 62, 212,
        ])!,
    ]

    static let testNetRootEntropies = [
        // account key 0
        Data32([
            57, 64, 36, 34, 253, 168, 193, 183, 146, 2, 30, 146, 134, 58, 30, 233, 124, 243, 35,
            126, 176, 173, 243, 20, 41, 104, 146, 153, 80, 148, 20, 48,
        ])!,
        // account key 1
        Data32([
            227, 94, 158, 200, 52, 129, 101, 85, 121, 22, 93, 190, 148, 22, 111, 171, 145, 3, 53,
            220, 163, 86, 57, 98, 104, 19, 198, 136, 161, 179, 199, 127,
        ])!,
        // account key 2
        Data32([
            173, 182, 129, 76, 134, 210, 252, 250, 203, 30, 74, 57, 23, 55, 111, 200, 132, 161, 196,
            67, 203, 95, 25, 254, 140, 242, 186, 156, 104, 214, 85, 10,
        ])!,
        // account key 3
        Data32([
            119, 220, 28, 201, 169, 199, 164, 75, 172, 57, 232, 184, 172, 127, 120, 8, 104, 157,
            155, 139, 237, 66, 98, 35, 252, 242, 98, 130, 254, 43, 253, 110,
        ])!,
        // account key 4
        Data32([
            102, 234, 28, 58, 187, 22, 137, 208, 215, 73, 181, 106, 150, 49, 231, 187, 224, 231, 16,
            63, 0, 196, 239, 112, 74, 190, 174, 104, 232, 25, 47, 121,
        ])!,
        // account key 5
        Data32([
            48, 128, 100, 126, 37, 102, 177, 248, 254, 97, 31, 189, 148, 138, 59, 78, 16, 73, 32,
            219, 42, 153, 255, 180, 112, 64, 209, 20, 17, 202, 48, 72,
        ])!,
    ]

    var fogAuthoritySpkiB64Encoded: String {
        switch self {
        case .test:
            return """
                MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvrTepNGRH5Qd4NgfF12XccoCW9RdZA1BSGUZP1w\
                59oyf5WoTmeSzJ+nB/YJ4WwHUZ7AoD2D2Kxm5cslANPweAVX4OOpeuXNw3V+nbrikPVGGE57nih/2GKEYFb\
                tqDEC32+vyVvhe3zzOZFFHH0r6xfu/qYds10Z/u1eTuWafMd+Yf0KnvSQL3FwRBS13v1vnoQ3Nj2DMNur/D\
                6Em4QnO836WhrcVZ+tqevwyLxTwQf0D0uslzc7u1Ap6bwqxxTDCSRXAlnEDJZ66KuhDU6bpqK3RCb/aUlDK\
                sjyjQT5v/AMMqNJNYNkFiBiYqM+raTw7V6jWha4daM6ZLpXqhXWhqfhUlNqCMAi0lw1Z33tM662OzBnpOEX\
                O/h8zhdRWO0l0IJt+Xaca2ZCaD7WE3F+JA6Xi9v/isGmjY1cTCH3yAK3Zfcju2kNetScI/zzUDPcI8j1Bi4\
                YKVWC3dAhmckX9QdpAThDwtr7xGQXfA+O6dPxL3WYSwcgDOhkbTreW4ay+F9IHO595ShMxepjJLlrq2BUQC\
                DbEVkn+oVWmrsnPvZuHBeFMB26v2xRACXwYRVUYRuPP9X08tcMSQfGpaIC6gb2T2qIG82IklxhnCmkaqT5o\
                ixUL2XZ1ROrh1njrEd4zc3+V4vEdC8YJHQ9idZ3WuaCkRLaFvDf52M1G59yU3E0CAwEAAQ==
                """
        case .alpha:
            return """
                MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyFOockvCEc9TcO1NvsiUfFVzvtDsR64UIRRUl3t\
                BM2Bh8KBA932/Up86RtgJVnbslxuUCrTJZCV4dgd5hAo/mzuJOy9lAGxUTpwWWG0zZJdpt8HJRVLX76CBpW\
                rWEt7JMoEmduvsCR8q7WkSNgT0iIoSXgT/hfWnJ8KGZkN4WBzzTH7hPrAcxPrzMI7TwHqUFfmOX7/gc+bDV\
                5ZyRORrpuu+OR2BVObkocgFJLGmcz7KRuN7/dYtdYFpiKearGvbYqBrEjeo/15chI0Bu/9oQkjPBtkvMBYj\
                yJPrD7oPP67i0ZfqV6xCj4nWwAD3bVjVqsw9cCBHgaykW8ArFFa0VCMdLy7UymYU5SQsfXrw/mHpr27Pp2Z\
                0/7wpuFgJHL+0ARU48OiUzkXSHX+sBLov9X6f9tsh4q/ZRorXhcJi7FnUoagBxewvlfwQfcnLX3hp1wqoRF\
                C4w1DC+ki93vIHUqHkNnayRsf1n48fSu5DwaFfNvejap7HCDIOpCCJmRVR8mVuxi6jgjOUa4Vhb/GCzxfNI\
                n5ZYym1RuoE0TsFO+TPMzjed3tQvG7KemGFz3pQIryb43SbG7Q+EOzIigxYDytzcxOO5Jx7r9i+amQEiIcj\
                BICwyFoEUlVJTgSpqBZGNpznoQ4I2m+uJzM+wMFsinTZN3mp4FU5UHjQsHKG+ZMCAwEAAQ==
                """
        case .mobiledev:
            return """
                MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxABZ75QZv9uH9/E823VTTmpWiOiehoqksZMqsDA\
                RqYdDexAQb1Y+qyT6Hlp5QMUHQlkomFKLnhe/0+wxZ1/uTqnhy2FRhrlclpOvczT10Smcx9RkKACpxCW095\
                MWxeFwtMmLpqkXfl4KeMptxdHRASHuLlKL+FXwOqKw3J2nw5q2DpBsg1ONkdW4m55ZFdimX3M7T/Wur5WlB\
                +ntBpKFU/5T+rdD3OUm/tExbYk7C58XmYW08TnFR9JOMekFZMmTfl5d1ee3koyzz225QfNEupUJDVMXcg4w\
                hp826arxQIXrM2DfgwZnxFqS617dNsOPNjIoAYSEFPczYTw9WHR7O3UISnYwYvCsXxGwLZLXFkgUBM5GKIt\
                vEHDbUh3C7ZjyM51A04EJg47G3nI1A6q9EVnmwGaZFxq8bJAzosn5zaSrbUA25hRff25C4BYNjydBI133Pj\
                SflLaGjnJYPruLO4XpzB3wszqKm3tiWN39sgC4sMWZfSlxlWox3SzY2XVl8Q9RqMO8LMUPNhwmTfpEXDW5+\
                NqH+vMiH9UmnsiEwybFche4sE23NJTeO2Xytt55VfoD2Gidte/Sqt5AJUPu6nfK8QloOCZ1N99MrpWpcZPH\
                ittqaYHZ5lWXHKthp/im672hXPl8bNxMUoREqomZdD9mdj/P6w9zFeTkr7P9XQUCAwEAAQ==
                """
        case .master:
            return """
                MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA6LVknCYxiXCIidHd+zQbTPEsXcSppPl1pEEr9jm\
                v5kEKae8tBoA4hDMZHBrd+qv2BTz1WoQCk396uI7q/MjsyaRDWgKvnbPepPczC67n/P2RXeAmI3+xEkxwaX\
                9DqPhd+KpeIqlnSNAKy/N+jG2I/RhCJRHlXmW1zE1vLD1RdHSqT+4F84ZXrfWuBn9uNxukcu6O4syMbEBl0\
                Qqzh3xUeTQTp7TSdZeiHVrbNTvcS/XtaKjroPZmqEXO+9abT/bQ42r8BPromVJY4LTqW+jYnDhAKuFRF29f\
                MVHaAeILWxhXsQ/yIA+eWOo8CGIjpS1Md7pzTwD1zDI6dv+kt7OpnhWLncJsl5OSEboy7pOy4BoXiNkky9+\
                A0tBitnaPNauSCb9Zhs1dXIwpUoGKhosYLexpmn9e+0exom6MVaQ73cpeuXCUQFq9QhkYp0p0uCVPV9Na8D\
                9bR4C9MTcxqS13bFayP+yC7EtQdlR7benbKD0qS8DykzPuoMCROLRAkEuK3NYf5EWwhILY366QqUjyVvA3m\
                0t2enBGrh6Cy7A0axkm8KxN2++wWvF5yl/NZLTq6KtB6u0cbQ9HFqbi2AgCux6AA0BZn5COaCkjC6VPpqlp\
                tGe0ePKaKZ7CEjP4gYPSNJoV9arEpbG+WtaLgHEhi+KDRGLkUFitBwRAexRENO8CAwEAAQ==
                """
        case .build:
            return """
                MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwCjpijWJqqypoJCcNIM9NsY/S5mx1OMqWZtlzed\
                aHQoRPkFxdYMM+BYLR0jX4nKoFsGziYqKS2Hqi87Li956BO3N8ZU+F6ON/GlQo/AOzKRdgd3eiOvvOXPtn4\
                ZlKudN0Y8/PO1KtrUSPUgsmGe9cleVPaiBUK2xnJ2Ea6Qpo3+oqbDLDzbAJwFcfKGT/hvfPGe7qOWJhM1hc\
                T6kuR7CT8NpIwyNg5nydTfWbxsKIFkB1BoRi2nyQ5ubXwU+vbcBsIkMNBbKeesW7uDumXpxKl50F6kAmpOY\
                IAH6QnePkX8yZNkAvhjBGm0QwJNC8iyITgxh/7f/L0zsKGixxijQoZatLnJo4sOHMtrAMPh1TyG6IzJsDng\
                R9dNyPk8aKP450lYSzutk3b0u+ZaWTjZZR3zKTUnNbEDIIfdlqT+BWwT/MX6j8PsXOVdBtDLcS0dUYTXuGT\
                h1TFYB3nDxdUJKpNEoaN8Rn++hklnt6BuoS9VXTILrB519XyXi4h8kLPcN93+q8tZSge+x5iURh7IR+pvqH\
                LumgEF7uiDa1jzQdzo/FCG6S884WrVS3C71kgS4uYhNJ6W95KZ4aNNh/JJpjkIp/XEZGfJIWVPVbYx5pXRW\
                +Ur59cueNksAqHonuTz+3pkLx7Uuz59PCSbNmA+WNxSq1UA0xh9ha5ni4tLkoEsCAwEAAQ==
                """
        case .demo:
            return """
                MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1i3oSWg9ItKJC+SedJehejPliQG3ODmAZEI//2O\
                oMgQ1cV5vut6sGbJAz4y3BUdZe1qN3EJQYkdqNphHRWZZiTXaG3xTwbCERhUMUCmi0HTR/EuYjx/7Ioy+IM\
                3rmAtPF07+wLvlwLiRPQu7+1Nciz4JNlomR3gLtVBFDxKQwXjh1Na2weKZaudBYUIA7A67HLLJNxmfZ8Clq\
                y1nRza44tzA7bku35oB3gFjXm6dGh6YJ8AkFBiTWVrId3uGlFu/nZR1Cnjqg04JKV439dtCpf4dJqiwj2+P\
                L3/I4HGJpJaTVX4Ik0ibiJmxbS5lhpTC+2PzPcIvrZ5JqKrr6QpswmDICkG+M679goMnp5L7N3dArPU7f4j\
                STrOaROag/mU2rNwboe3Qz8NwKOYP2+dvn3Rr6C5Y3IX6jCnSSNYxTyQvhbiENdENnXlQVTjOTreNuos7ha\
                lBA7dN3pa6PN8lNLIFaaEsu/QuNgC5mdXLE0AlHPiMkOPnREPH5qUTo4ZzsOEUU3igQbOQWZ0O0HtloqoEE\
                3HB6qnFux0QAlI7RX5Y+ZddQRk7Qthx+QOw67UZCbU+/kBXlAnIBtoMM5C4H7FIp6dgaHdQn7DGM6KRTBPR\
                ShbnXM4jaVaYfzQ5CXznDhlSsnOr4CVobWhC1lEL0qoAr5a2J7sJ7M+Vipd7t9kCAwEAAQ==
                """
        case .diogenes:
            return """
                MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAuQORYYEiUvyYheAMyffl4IIT7apxFhBmKgqP5ez\
                6sd+fbZUUsshTJQ2ksb0FsWJT2DpqIb8YrZr5o2HUrJ6bfxQqiGWFwHfFeb39JIxztDWoDcfng1EKG/1yH4\
                q0JAxoeI4kOKtX11WWFoKN/1NAWyUzOyQhoQRtJSXUE0b0VwqOYVbvbJf+yFC3FHghEqEdOoO+Ux8pTU2s0\
                0bjnRq8WWhGhJ+v1DLbElvBIHP6CBM2aDJtIgvwxyGsa8L8XqMZlRO6fXP08CGdI11K4QC+oO2m9V4pzTAX\
                v7v+VX9aO8kBJm5087HumfeFosFdqV56X/1J95jnTh8VuWuyW6beNo4znBhuN0/nsEUp2ZgR06cXzyKm62M\
                uE33DiVVBSi3FrJbw2neC+mEgLQmgSrsF6+uJMDWWgj/55h5Vu6ovq3o5yS26MjrVdp8Dn7HZZFf+UldWS3\
                iBDznQTBL7ePwTv+Mze55R6dyDy7iZjt9OEt1VEPZAWU33NEP5rjnjloIgDNfNoUaT3y2rJ3bmO28TkKJOg\
                iIniTpboHDw27FkLG1LTrveV19d/JCMcN+OWgHyEbIhJ3CUdZx3mzDlXyGw2crdGrdp5lx+Ms8oJeVW97a7\
                98FHA58JD1rkLtYfGreYT5EIypbTW34kmj/U9dawLVaTMp1DDa/KT9kWpWe+7GMCAwEAAQ==
                """
        case .drakeley:
            return """
                MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvNL/KfQYAgpr9AAlbjdXHjvJej6SOTqNuoYeOA2\
                MAGKNDoElCD5dilkQVkneUTbSoT/uJzHfXMjfuYT4u4lQQzy9OSTf3eNxxuVCfH+WFGzJ3WsA1H1PXB/pct\
                JDK+O1CPBcM0QVfQc9qeieoKat6B8Zg7I703H1/9iinAwaOdmDjHLqMwGFqsQTJ/sU/TvLMLm0CHD+exGj+\
                8rEiyHUfcQF36MzckvBtWUqc5lx/KjqDtGdebD38Tp3yXPHgKcFyh5KCT5LxCxhbk/9xMZ3wqaDLoYgXrPm\
                XmMeffFO0/QoRfpXm4rYqSysSbQX1Enpsexx7A4H8W7uNFMdiYpHzW6ZAoaoqf/lLRpvadUx7v4fROLC6v4\
                0Ff35i0CMN2THR0BQQfq767cd9r5RlcJpmbW0TCHYDub1r5WGjxB6N05cDvdyfi/9M0EbADv1ca9PGjgjiL\
                FyugNPQIZbcLojq8mnet/DUOs9wjV0AYcG2sMuKzOATeg6hcWtQCHjPhESOhu6eULHIZ/4KxddK0qDyNPPm\
                bMeLPU01b+rLk9XhJjM5opMjZ4Ed6WRRler7GbgEwqQ0SWYEEkFUf4tl3h2Uj+X51s83q/OFRGdktz4eBGC\
                1BCHVlaT3RAmWRdZyj4Kj/K4vzQUKUzmqEiI/iN2fhEI5MQQuzgDiZ1g9eDC0RcCAwEAAQ==
                """
        case .eran:
            return """
                MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAr8Oav7dkb95mov7iDWJNTldFy+hNo6+LowBFGrg\
                4FW+VzuOeY3eRC2J5jMr2cC6yyr5U5o1vaXt0YQanLSVomm+at2kzuKXQaVhsl3tSNN9X5Kvn2IMH3CSYiE\
                D9rtforrLbgm1SWnT776MCOe5F9n+UyyDHEXtiVoGBI6dKRoJf8ZhrQt98qMOi9tlsOVbVcpwlURPxHGMeB\
                SegDRGSZB1crMxZpja5PvXZ+0UtCPZ5f3ouSaRZmVA4x9GijjmNmROnGOL3H4FPe848bJHY9iqkYjfVj+jV\
                +iHqgR5TYSfPEiN261FuQBpAVfTy1ijKvBAQjZx8Lc4snl6ao+Beq277V+AWLEkKpO1PhMcpbgFrWz/dD8Q\
                EP+69iDXnsWbnG/hH90AT1OetOxMlkfjRPy6RWsOtKXHGCxOEavubMdvMJODVHN/RoA9Hsh5s+3i6qu2pQv\
                3CLhZy0+10mMM6feAbH0s2hmK3b3nafVp1jztlIVeBEBCINagR2lvcFvixKvFahzRwIt3uS85IeU7ikj3GV\
                giYUQ6s1zYdf60te6GKV5mDDkMB4uB8qtqN+F8+K9A18gWOlxyq0m2NHQxQjYk7Lz7PCQwTvXvTYmm4GOkG\
                sR/XCdpWQnNvATqNY1wqDm/bHrNQuKpOFY2Ugeakz9yruw8hUO0qn+XEl6ra+LsCAwEAAQ==
                """
        }
    }

    /// MobileCoin-managed Consensus and Fog services use Let's Encrypt with an intermediate
    /// certificate that's cross-signed by IdenTrust's "DST Root CA X3": https://crt.sh/?d=8395
    static let trustRootsB64 = """
        MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/MSQwIgYDVQQKExtEaWdpdGFsIFN\
        pZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMTDkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMD\
        E0MDExNVowPzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQDEw5EU1QgUm9vdCBDQ\
        SBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgU\
        i+DoM3ZJKuM/IUmTrE4Orz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEqOLl5CjH\
        9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9bxiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5W\
        gTe1QLyNau7Fqckh49ZLOMxt+/yUFw7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicP\
        NaDaeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0O\
        BBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqGSIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSB\
        d49lZRNI+DT69ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXrAvHRAosZy5Q6Xk\
        jEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZzR8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZIm\
        lJnt1ir/md2cXjbDaJWFBM5JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYoOb8V\
        ZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
        """

}
