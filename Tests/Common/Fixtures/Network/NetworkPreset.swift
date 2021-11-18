//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable file_length inclusive_language multiline_function_chains

@testable import MobileCoin
import NIOSSL
import XCTest

#if canImport(Keys)
import Keys
#endif

enum NetworkPreset {
    /// MainNet (MobileCoin Consensus node1 + MobileCoin Fog)
    case mainNet

    /// External TestNet (MobileCoin Consensus node1 + MobileCoin Fog)
    case testNet

    /// Internal staging network
    case alpha

    /// Internal mobile development network
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

extension NetworkPreset {
    private enum Network {
        case mainNet
        case testNet

        case alpha
        case mobiledev
        case master
        case build
        case demo
        case diogenes
        case drakeley
        case eran
    }

    private var network: Network {
        switch self {
        case .mainNet:
            return .mainNet
        case .testNet:
            return .testNet

        case .alpha:
            return .alpha
        case .mobiledev:
            return .mobiledev
        case .master:
            return .master
        case .build:
            return .build
        case .demo:
            return .demo
        case .diogenes:
            return .diogenes
        case .drakeley:
            return .drakeley
        case .eran:
            return .eran
        }
    }
}

extension NetworkPreset {
    private enum NetworkGroup {
        case mainNet
        case testNet
        case devNetwork
    }

    private var networkGroup: NetworkGroup {
        switch network {
        case .mainNet:
            return .mainNet
        case .testNet:
            return .testNet

        case .alpha, .mobiledev, .master, .build, .demo, .diogenes, .drakeley, .eran:
            return .devNetwork
        }
    }
}

extension NetworkPreset {

    var consensusUrl: String {
        switch self {
        case .mainNet:
            return "mc://node1.prod.mobilecoinww.com"
        case .testNet:
            return "mc://node1.test.mobilecoin.com"

        case .alpha, .mobiledev, .master, .build, .demo, .diogenes, .drakeley, .eran:
            return "mc://node1.\(self).mobilecoin.com"
        }
    }
    var fogUrl: String {
        switch self {
        case .mainNet:
            return "fog://fog.prod.mobilecoinww.com"
        case .testNet:
            return "fog://fog.test.mobilecoin.com"

        case .alpha, .mobiledev, .master, .build, .demo, .diogenes, .drakeley, .eran:
            return "fog://fog.\(self).mobilecoin.com"
        }
    }

    private static let mainNetConsensusMrEnclaveHex =
        "653228afd2b02a6c28f1dc3b108b1dfa457d170b32ae8ec2978f941bd1655c83"
    private static let mainNetFogViewMrEnclaveHex =
        "dd84abda7f05116e21fcd1ee6361b0ec29445fff0472131eaf37bf06255b567a"
    private static let mainNetFogLedgerMrEnclaveHex =
        "89db0d1684fcc98258295c39f4ab68f7de5917ef30f0004d9a86f29930cebbbd"
    private static let mainNetFogReportMrEnclaveHex =
        "f3f7e9a674c55fb2af543513527b6a7872de305bac171783f6716a0bf6919499"
    
//    private static let mainNetConsensusMrEnclaveHex =
//        "e66db38b8a43a33f6c1610d335a361963bb2b31e056af0dc0a895ac6c857cab9"
//    private static let mainNetFogViewMrEnclaveHex =
//        "ddd59da874fdf3239d5edb1ef251df07a8728c9ef63057dd0b50ade5a9ddb041"
//    private static let mainNetFogLedgerMrEnclaveHex =
//        "511eab36de691ded50eb08b173304194da8b9d86bfdd7102001fe6bb279c3666"
//    private static let mainNetFogReportMrEnclaveHex =
//        "709ab90621e3a8d9eb26ed9e2830e091beceebd55fb01c5d7c31d27e83b9b0d1"

    private static let testNetConsensusMrEnclaveHex =
        "9659ea738275b3999bf1700398b60281be03af5cb399738a89b49ea2496595af"
    private static let testNetFogViewMrEnclaveHex =
        "e154f108c7758b5aa7161c3824c176f0c20f63012463bf3cc5651e678f02fb9e"
    private static let testNetFogLedgerMrEnclaveHex =
        "768f7bea6171fb83d775ee8485e4b5fcebf5f664ca7e8b9ceef9c7c21e9d9bf3"
    private static let testNetFogReportMrEnclaveHex =
        "a4764346f91979b4906d4ce26102228efe3aba39216dec1e7d22e6b06f919f11"

    private static let devMrSignerHex =
        "7ee5e29d74623fdbc6fbf1454be6f3bb0b86c12366b7b478ad13353e44de8411"

    private static let mainNetFogAuthoritySpkiB64Encoded = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyr/99fvxi104MLgDgvWPVt01TuTJ+rN4qcNBUbF5i3EMM5z\
        DZlugFHKPYPv7flCh5yDDYyLQHfWkxPQqCBAqlhSrCakvQH3HqDSpbM5FJg7pt0k5w+UQGWvP079iSEO5fMRhjE/lOR\
        kvk3/UKr2yIXjZ19iEgP8hlhk9xkI42DSg0iIhk59k3wEYPMGSkVarqlPoKBzx2+11CieXnbCkRvoNwLvdzLceY8QNo\
        Lc6h2/nht4bcjDCdB0MKNSKFLVp6XNHkVF66jC7QWTZRA/d4pgI5xa+GmkQ90zDZC2sBc+xfquVIVtk0nEvqSkUDZjv\
        7AcJaq/VdPu4uj773ojrZz094PI4Q6sdbg7mfWrcq3ZQG8t9RDXD+6cgugCTFx2Cq/vJhDAPbQHmCEaMoXv2sRSfOhR\
        jtMP1KmKUw5zXmAZa7s88+e7UXRQC+SS77V8s3hinE/I5Gqa/lzl73smhXx8l4CwGnXzlQ5h1lgEHnYLRFnIenNw/md\
        MGKlWH5HwHLX3hIujERCPAnGLDt+4MjcUiU0spDH3hC9mjPVA3ltaA3+Mk2lDw0kLrZ4Gv3/Ik9WPlYetOuWteMkR1f\
        z6VOc13+WoTJPz0dVrJsK2bUz+YvdBsoHQBbUpCkmnQ5Ok+yiuWa5vYikEJ24SEr8wUiZ4Oe12KVEcjyDIxp6QoE8kC\
        AwEAAQ==
        """
    private static let testNetFogAuthoritySpkiB64Encoded = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvnB9wTbTOT5uoizRYaYbw7XIEkInl8E7MGOAQj+xnC+F1rI\
        XiCnc/t1+5IIWjbRGhWzo7RAwI5sRajn2sT4rRn9NXbOzZMvIqE4hmhmEzy1YQNDnfALAWNQ+WBbYGW+Vqm3IlQvAFF\
        jVN1YYIdYhbLjAPdkgeVsWfcLDforHn6rR3QBZYZIlSBQSKRMY/tywTxeTCvK2zWcS0kbbFPtBcVth7VFFVPAZXhPi9\
        yy1AvnldO6n7KLiupVmojlEMtv4FQkk604nal+j/dOplTATV8a9AJBbPRBZ/yQg57EG2Y2MRiHOQifJx0S5VbNyMm9b\
        kS8TD7Goi59aCW6OT1gyeotWwLg60JRZTfyJ7lYWBSOzh0OnaCytRpSWtNZ6barPUeOnftbnJtE8rFhF7M4F66et0LI\
        /cuvXYecwVwykovEVBKRF4HOK9GgSm17mQMtzrD7c558TbaucOWabYR04uhdAc3s10MkuONWG0wIQhgIChYVAGnFLvS\
        pp2/aQEq3xrRSETxsixUIjsZyWWROkuA0IFnc8d7AmcnUBvRW7FT/5thWyk5agdYUGZ+7C1o69ihR1YxmoGh69fLMPI\
        EOhYh572+3ckgl2SaV4uo9Gvkz8MMGRBcMIMlRirSwhCfozV2RyT5Wn1NgPpyc8zJL7QdOhL7Qxb+5WjnCVrQYHI2cC\
        AwEAAQ==
        """

    private static let alphaFogAuthoritySpkiB64Encoded = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyFOockvCEc9TcO1NvsiUfFVzvtDsR64UIRRUl3tBM2Bh8KB\
        A932/Up86RtgJVnbslxuUCrTJZCV4dgd5hAo/mzuJOy9lAGxUTpwWWG0zZJdpt8HJRVLX76CBpWrWEt7JMoEmduvsCR\
        8q7WkSNgT0iIoSXgT/hfWnJ8KGZkN4WBzzTH7hPrAcxPrzMI7TwHqUFfmOX7/gc+bDV5ZyRORrpuu+OR2BVObkocgFJ\
        LGmcz7KRuN7/dYtdYFpiKearGvbYqBrEjeo/15chI0Bu/9oQkjPBtkvMBYjyJPrD7oPP67i0ZfqV6xCj4nWwAD3bVjV\
        qsw9cCBHgaykW8ArFFa0VCMdLy7UymYU5SQsfXrw/mHpr27Pp2Z0/7wpuFgJHL+0ARU48OiUzkXSHX+sBLov9X6f9ts\
        h4q/ZRorXhcJi7FnUoagBxewvlfwQfcnLX3hp1wqoRFC4w1DC+ki93vIHUqHkNnayRsf1n48fSu5DwaFfNvejap7HCD\
        IOpCCJmRVR8mVuxi6jgjOUa4Vhb/GCzxfNIn5ZYym1RuoE0TsFO+TPMzjed3tQvG7KemGFz3pQIryb43SbG7Q+EOzIi\
        gxYDytzcxOO5Jx7r9i+amQEiIcjBICwyFoEUlVJTgSpqBZGNpznoQ4I2m+uJzM+wMFsinTZN3mp4FU5UHjQsHKG+ZMC\
        AwEAAQ==
        """
    private static let mobiledevFogAuthoritySpkiB64Encoded = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxABZ75QZv9uH9/E823VTTmpWiOiehoqksZMqsDARqYdDexA\
        Qb1Y+qyT6Hlp5QMUHQlkomFKLnhe/0+wxZ1/uTqnhy2FRhrlclpOvczT10Smcx9RkKACpxCW095MWxeFwtMmLpqkXfl\
        4KeMptxdHRASHuLlKL+FXwOqKw3J2nw5q2DpBsg1ONkdW4m55ZFdimX3M7T/Wur5WlB+ntBpKFU/5T+rdD3OUm/tExb\
        Yk7C58XmYW08TnFR9JOMekFZMmTfl5d1ee3koyzz225QfNEupUJDVMXcg4whp826arxQIXrM2DfgwZnxFqS617dNsOP\
        NjIoAYSEFPczYTw9WHR7O3UISnYwYvCsXxGwLZLXFkgUBM5GKItvEHDbUh3C7ZjyM51A04EJg47G3nI1A6q9EVnmwGa\
        ZFxq8bJAzosn5zaSrbUA25hRff25C4BYNjydBI133PjSflLaGjnJYPruLO4XpzB3wszqKm3tiWN39sgC4sMWZfSlxlW\
        ox3SzY2XVl8Q9RqMO8LMUPNhwmTfpEXDW5+NqH+vMiH9UmnsiEwybFche4sE23NJTeO2Xytt55VfoD2Gidte/Sqt5AJ\
        UPu6nfK8QloOCZ1N99MrpWpcZPHittqaYHZ5lWXHKthp/im672hXPl8bNxMUoREqomZdD9mdj/P6w9zFeTkr7P9XQUC\
        AwEAAQ==
        """
    private static let masterFogAuthoritySpkiB64Encoded = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA6LVknCYxiXCIidHd+zQbTPEsXcSppPl1pEEr9jmv5kEKae8\
        tBoA4hDMZHBrd+qv2BTz1WoQCk396uI7q/MjsyaRDWgKvnbPepPczC67n/P2RXeAmI3+xEkxwaX9DqPhd+KpeIqlnSN\
        AKy/N+jG2I/RhCJRHlXmW1zE1vLD1RdHSqT+4F84ZXrfWuBn9uNxukcu6O4syMbEBl0Qqzh3xUeTQTp7TSdZeiHVrbN\
        TvcS/XtaKjroPZmqEXO+9abT/bQ42r8BPromVJY4LTqW+jYnDhAKuFRF29fMVHaAeILWxhXsQ/yIA+eWOo8CGIjpS1M\
        d7pzTwD1zDI6dv+kt7OpnhWLncJsl5OSEboy7pOy4BoXiNkky9+A0tBitnaPNauSCb9Zhs1dXIwpUoGKhosYLexpmn9\
        e+0exom6MVaQ73cpeuXCUQFq9QhkYp0p0uCVPV9Na8D9bR4C9MTcxqS13bFayP+yC7EtQdlR7benbKD0qS8DykzPuoM\
        CROLRAkEuK3NYf5EWwhILY366QqUjyVvA3m0t2enBGrh6Cy7A0axkm8KxN2++wWvF5yl/NZLTq6KtB6u0cbQ9HFqbi2\
        AgCux6AA0BZn5COaCkjC6VPpqlptGe0ePKaKZ7CEjP4gYPSNJoV9arEpbG+WtaLgHEhi+KDRGLkUFitBwRAexRENO8C\
        AwEAAQ==
        """
    private static let buildFogAuthoritySpkiB64Encoded = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwCjpijWJqqypoJCcNIM9NsY/S5mx1OMqWZtlzedaHQoRPkF\
        xdYMM+BYLR0jX4nKoFsGziYqKS2Hqi87Li956BO3N8ZU+F6ON/GlQo/AOzKRdgd3eiOvvOXPtn4ZlKudN0Y8/PO1Ktr\
        USPUgsmGe9cleVPaiBUK2xnJ2Ea6Qpo3+oqbDLDzbAJwFcfKGT/hvfPGe7qOWJhM1hcT6kuR7CT8NpIwyNg5nydTfWb\
        xsKIFkB1BoRi2nyQ5ubXwU+vbcBsIkMNBbKeesW7uDumXpxKl50F6kAmpOYIAH6QnePkX8yZNkAvhjBGm0QwJNC8iyI\
        Tgxh/7f/L0zsKGixxijQoZatLnJo4sOHMtrAMPh1TyG6IzJsDngR9dNyPk8aKP450lYSzutk3b0u+ZaWTjZZR3zKTUn\
        NbEDIIfdlqT+BWwT/MX6j8PsXOVdBtDLcS0dUYTXuGTh1TFYB3nDxdUJKpNEoaN8Rn++hklnt6BuoS9VXTILrB519Xy\
        Xi4h8kLPcN93+q8tZSge+x5iURh7IR+pvqHLumgEF7uiDa1jzQdzo/FCG6S884WrVS3C71kgS4uYhNJ6W95KZ4aNNh/\
        JJpjkIp/XEZGfJIWVPVbYx5pXRW+Ur59cueNksAqHonuTz+3pkLx7Uuz59PCSbNmA+WNxSq1UA0xh9ha5ni4tLkoEsC\
        AwEAAQ==
        """
    private static let demoFogAuthoritySpkiB64Encoded = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1i3oSWg9ItKJC+SedJehejPliQG3ODmAZEI//2OoMgQ1cV5\
        vut6sGbJAz4y3BUdZe1qN3EJQYkdqNphHRWZZiTXaG3xTwbCERhUMUCmi0HTR/EuYjx/7Ioy+IM3rmAtPF07+wLvlwL\
        iRPQu7+1Nciz4JNlomR3gLtVBFDxKQwXjh1Na2weKZaudBYUIA7A67HLLJNxmfZ8Clqy1nRza44tzA7bku35oB3gFjX\
        m6dGh6YJ8AkFBiTWVrId3uGlFu/nZR1Cnjqg04JKV439dtCpf4dJqiwj2+PL3/I4HGJpJaTVX4Ik0ibiJmxbS5lhpTC\
        +2PzPcIvrZ5JqKrr6QpswmDICkG+M679goMnp5L7N3dArPU7f4jSTrOaROag/mU2rNwboe3Qz8NwKOYP2+dvn3Rr6C5\
        Y3IX6jCnSSNYxTyQvhbiENdENnXlQVTjOTreNuos7halBA7dN3pa6PN8lNLIFaaEsu/QuNgC5mdXLE0AlHPiMkOPnRE\
        PH5qUTo4ZzsOEUU3igQbOQWZ0O0HtloqoEE3HB6qnFux0QAlI7RX5Y+ZddQRk7Qthx+QOw67UZCbU+/kBXlAnIBtoMM\
        5C4H7FIp6dgaHdQn7DGM6KRTBPRShbnXM4jaVaYfzQ5CXznDhlSsnOr4CVobWhC1lEL0qoAr5a2J7sJ7M+Vipd7t9kC\
        AwEAAQ==
        """
    private static let diogenesFogAuthoritySpkiB64Encoded = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAuQORYYEiUvyYheAMyffl4IIT7apxFhBmKgqP5ez6sd+fbZU\
        UsshTJQ2ksb0FsWJT2DpqIb8YrZr5o2HUrJ6bfxQqiGWFwHfFeb39JIxztDWoDcfng1EKG/1yH4q0JAxoeI4kOKtX11\
        WWFoKN/1NAWyUzOyQhoQRtJSXUE0b0VwqOYVbvbJf+yFC3FHghEqEdOoO+Ux8pTU2s00bjnRq8WWhGhJ+v1DLbElvBI\
        HP6CBM2aDJtIgvwxyGsa8L8XqMZlRO6fXP08CGdI11K4QC+oO2m9V4pzTAXv7v+VX9aO8kBJm5087HumfeFosFdqV56\
        X/1J95jnTh8VuWuyW6beNo4znBhuN0/nsEUp2ZgR06cXzyKm62MuE33DiVVBSi3FrJbw2neC+mEgLQmgSrsF6+uJMDW\
        Wgj/55h5Vu6ovq3o5yS26MjrVdp8Dn7HZZFf+UldWS3iBDznQTBL7ePwTv+Mze55R6dyDy7iZjt9OEt1VEPZAWU33NE\
        P5rjnjloIgDNfNoUaT3y2rJ3bmO28TkKJOgiIniTpboHDw27FkLG1LTrveV19d/JCMcN+OWgHyEbIhJ3CUdZx3mzDlX\
        yGw2crdGrdp5lx+Ms8oJeVW97a798FHA58JD1rkLtYfGreYT5EIypbTW34kmj/U9dawLVaTMp1DDa/KT9kWpWe+7GMC\
        AwEAAQ==
        """
    private static let drakeleyFogAuthoritySpkiB64Encoded = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvNL/KfQYAgpr9AAlbjdXHjvJej6SOTqNuoYeOA2MAGKNDoE\
        lCD5dilkQVkneUTbSoT/uJzHfXMjfuYT4u4lQQzy9OSTf3eNxxuVCfH+WFGzJ3WsA1H1PXB/pctJDK+O1CPBcM0QVfQ\
        c9qeieoKat6B8Zg7I703H1/9iinAwaOdmDjHLqMwGFqsQTJ/sU/TvLMLm0CHD+exGj+8rEiyHUfcQF36MzckvBtWUqc\
        5lx/KjqDtGdebD38Tp3yXPHgKcFyh5KCT5LxCxhbk/9xMZ3wqaDLoYgXrPmXmMeffFO0/QoRfpXm4rYqSysSbQX1Enp\
        sexx7A4H8W7uNFMdiYpHzW6ZAoaoqf/lLRpvadUx7v4fROLC6v40Ff35i0CMN2THR0BQQfq767cd9r5RlcJpmbW0TCH\
        YDub1r5WGjxB6N05cDvdyfi/9M0EbADv1ca9PGjgjiLFyugNPQIZbcLojq8mnet/DUOs9wjV0AYcG2sMuKzOATeg6hc\
        WtQCHjPhESOhu6eULHIZ/4KxddK0qDyNPPmbMeLPU01b+rLk9XhJjM5opMjZ4Ed6WRRler7GbgEwqQ0SWYEEkFUf4tl\
        3h2Uj+X51s83q/OFRGdktz4eBGC1BCHVlaT3RAmWRdZyj4Kj/K4vzQUKUzmqEiI/iN2fhEI5MQQuzgDiZ1g9eDC0RcC\
        AwEAAQ==
        """
    private static let eranFogAuthoritySpkiB64Encoded = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAr8Oav7dkb95mov7iDWJNTldFy+hNo6+LowBFGrg4FW+VzuO\
        eY3eRC2J5jMr2cC6yyr5U5o1vaXt0YQanLSVomm+at2kzuKXQaVhsl3tSNN9X5Kvn2IMH3CSYiED9rtforrLbgm1SWn\
        T776MCOe5F9n+UyyDHEXtiVoGBI6dKRoJf8ZhrQt98qMOi9tlsOVbVcpwlURPxHGMeBSegDRGSZB1crMxZpja5PvXZ+\
        0UtCPZ5f3ouSaRZmVA4x9GijjmNmROnGOL3H4FPe848bJHY9iqkYjfVj+jV+iHqgR5TYSfPEiN261FuQBpAVfTy1ijK\
        vBAQjZx8Lc4snl6ao+Beq277V+AWLEkKpO1PhMcpbgFrWz/dD8QEP+69iDXnsWbnG/hH90AT1OetOxMlkfjRPy6RWsO\
        tKXHGCxOEavubMdvMJODVHN/RoA9Hsh5s+3i6qu2pQv3CLhZy0+10mMM6feAbH0s2hmK3b3nafVp1jztlIVeBEBCINa\
        gR2lvcFvixKvFahzRwIt3uS85IeU7ikj3GVgiYUQ6s1zYdf60te6GKV5mDDkMB4uB8qtqN+F8+K9A18gWOlxyq0m2NH\
        QxQjYk7Lz7PCQwTvXvTYmm4GOkGsR/XCdpWQnNvATqNY1wqDm/bHrNQuKpOFY2Ugeakz9yruw8hUO0qn+XEl6ra+LsC\
        AwEAAQ==
        """

    private static let trustRootsB64 = [
        /// MobileCoin-managed Consensus and Fog services use Let's Encrypt with an intermediate
        /// certificate ISRG Root X1 that's self-signed https://crt.sh/?id=9314791
        """
            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
            """,
    ]

    private static let invalidCredUsername = "user1"
    private static let invalidCredPassword = "user1:1602033437:ffffffffffffffffffff"

    private static let devNetworkTestAccountPrivateKeysHex = [
        // account key 0
        ("e7a1cbbd97382b0d7532f31bf45e7d1628ba9127039d3650a371e6675ac7b40d",
         "bb9fd7c2faf1e4f66c979777eddfd79de81a7962a8e45a4fda5e7cd94bd0b000"),
        // account key 1
        ("fe7f68d45331d9f386f816e9a90dcc8b39cc9db8bba2ffd7337fd1bff9f4a601",
         "877be1fe01e037141ae6fa2ae032c4c0e0bbae385b811eebe543f154fa33f10e"),
        // account key 2
        ("c203ff741f6c988d9a3467fe96b0083d4d6cfedd3bdb98195c74fc8c608c6f07",
         "e202cbe05fc8ba0a4561719997a0e89b514e98e81a266d8d7ff02fb429b49401"),
        // account key 3
        ("1497e50403429a496410786f5005419859b8b392492a03793f4acd75b8db7f0b",
         "a44d34fa67db295c1bb220173d11fa7c39362f22663811349d373e3912087a0e"),
        // account key 4
        ("a20cbb25550ce5d35cf714fd49f904ad0ee211686b51dfce00d0cbbca731c10f",
         "f4bbafd7fa221bc488f7879cff65df586d49fdcfc3cd2c1a270e66585cb48008"),
        // account key 5
        ("1a2e559605b685dcd24224e29904e97d05858f19ef8c9c01c997b26ac6f1fb0f",
         "2fed1891e7c17d1a78933596434252d1be7f461ff8b5505f08476162f579b208"),
        // account key 6
        ("389b07fce6b0daf0a3434c6c555ba3e2ba096e5f8b6ec1e129f9e0160d3f240c",
         "41a0c650d0572ffdc5745dbba8f1f14f836e435bee221abd0916fe24d6951404"),
        // account key 7
        ("a2480ca6e0623206577b6567fb43d47c361f3d441b4871d8abf4e9a022ea3b08",
         "5ce48390a4b805f321abaf4aa5960773fa9c6ad34ed2d4bfe0155c5df01aab0f"),
    ]

}

final class TestHttpRequester: HttpRequester {
    let configuration : URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        return config
    }()
    
    func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<HTTPResponse, Error>) -> Void
    ) {
        var request = URLRequest(url: url.absoluteURL)
        request.httpMethod = method.rawValue
        headers?.forEach({ key, value in
            request.setValue(value, forHTTPHeaderField: key)
        })

        request.httpBody = body

        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: request) {data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(ConnectionError.invalidServerResponse("No Response")))
                return
            }
            let httpResponse = HTTPResponse(httpUrlResponse: response, responseData: data)
            completion(.success(httpResponse))
        }
        task.resume()
    }
}

extension NetworkPreset {

    func networkConfig(transportProtocol: TransportProtocol = TransportProtocol.grpc) throws -> NetworkConfig {
        let attestationConfig = try self.attestationConfig()
        var networkConfig = try NetworkConfig.make(
            consensusUrl: consensusUrl,
            fogUrl: fogUrl,
            attestation: attestationConfig,
            transportProtocol: transportProtocol).get()
        networkConfig.httpRequester = TestHttpRequester()
        networkConfig.consensusTrustRoots = try consensusTrustRoots()
        networkConfig.fogTrustRoots = try fogTrustRoots()
        networkConfig.consensusAuthorization = consensusCredentials
        networkConfig.fogUserAuthorization = fogUserCredentials
        return networkConfig
    }

    var fogReportUrl: String { fogUrl }
    var fogReportId: String { "" }

    func fogAuthoritySpki() throws -> Data {
        let fogAuthoritySpkiB64Encoded: String
        switch self {
        case .mainNet:
            fogAuthoritySpkiB64Encoded = Self.mainNetFogAuthoritySpkiB64Encoded
        case .testNet:
            fogAuthoritySpkiB64Encoded = Self.testNetFogAuthoritySpkiB64Encoded

        case .alpha:
            fogAuthoritySpkiB64Encoded = Self.alphaFogAuthoritySpkiB64Encoded
        case .mobiledev:
            fogAuthoritySpkiB64Encoded = Self.mobiledevFogAuthoritySpkiB64Encoded
        case .master:
            fogAuthoritySpkiB64Encoded = Self.masterFogAuthoritySpkiB64Encoded
        case .build:
            fogAuthoritySpkiB64Encoded = Self.buildFogAuthoritySpkiB64Encoded
        case .demo:
            fogAuthoritySpkiB64Encoded = Self.demoFogAuthoritySpkiB64Encoded
        case .diogenes:
            fogAuthoritySpkiB64Encoded = Self.diogenesFogAuthoritySpkiB64Encoded
        case .drakeley:
            fogAuthoritySpkiB64Encoded = Self.drakeleyFogAuthoritySpkiB64Encoded
        case .eran:
            fogAuthoritySpkiB64Encoded = Self.eranFogAuthoritySpkiB64Encoded
        }
        return try XCTUnwrap(Data(base64Encoded: fogAuthoritySpkiB64Encoded))
    }

    func attestationConfig() throws -> NetworkConfig.AttestationConfig {
        NetworkConfig.AttestationConfig(
            consensus: try consensusAttestation(),
            fogView: try fogViewAttestation(),
            fogKeyImage: try fogLedgerAttestation(),
            fogMerkleProof: try fogLedgerAttestation(),
            fogReport: try fogReportAttestation())
    }

    func consensusAttestation() throws -> Attestation {
        switch networkGroup {
        case .mainNet:
            return try defaultAttestation(mrEnclaveHex: Self.mainNetConsensusMrEnclaveHex)
        case .testNet:
            return try defaultAttestation(mrEnclaveHex: Self.testNetConsensusMrEnclaveHex)
        case .devNetwork:
            return try XCTUnwrapSuccess(Attestation.make(
                mrSigner: try XCTUnwrap(Data(hexEncoded: Self.devMrSignerHex)),
                productId: McConstants.CONSENSUS_PRODUCT_ID,
                minimumSecurityVersion: McConstants.CONSENSUS_SECURITY_VERSION,
                allowedHardeningAdvisories: ["INTEL-SA-00334"]))
        }
    }
    func fogViewAttestation() throws -> Attestation {
        switch networkGroup {
        case .mainNet:
            return try defaultAttestation(mrEnclaveHex: Self.mainNetFogViewMrEnclaveHex)
        case .testNet:
            return try defaultAttestation(mrEnclaveHex: Self.testNetFogViewMrEnclaveHex)
        case .devNetwork:
            return try XCTUnwrapSuccess(Attestation.make(
                mrSigner: try XCTUnwrap(Data(hexEncoded: Self.devMrSignerHex)),
                productId: McConstants.FOG_VIEW_PRODUCT_ID,
                minimumSecurityVersion: McConstants.FOG_VIEW_SECURITY_VERSION,
                allowedHardeningAdvisories: ["INTEL-SA-00334"]))
        }
    }
    func fogLedgerAttestation() throws -> Attestation {
        switch networkGroup {
        case .mainNet:
            return try defaultAttestation(mrEnclaveHex: Self.mainNetFogLedgerMrEnclaveHex)
        case .testNet:
            return try defaultAttestation(mrEnclaveHex: Self.testNetFogLedgerMrEnclaveHex)
        case .devNetwork:
            return try XCTUnwrapSuccess(Attestation.make(
                mrSigner: try XCTUnwrap(Data(hexEncoded: Self.devMrSignerHex)),
                productId: McConstants.FOG_LEDGER_PRODUCT_ID,
                minimumSecurityVersion: McConstants.FOG_LEDGER_SECURITY_VERSION,
                allowedHardeningAdvisories: ["INTEL-SA-00334"]))
        }
    }
    func fogReportAttestation() throws -> Attestation {
        switch networkGroup {
        case .mainNet:
            return try defaultAttestation(mrEnclaveHex: Self.mainNetFogReportMrEnclaveHex)
        case .testNet:
            return try defaultAttestation(mrEnclaveHex: Self.testNetFogReportMrEnclaveHex)
        case .devNetwork:
            return try XCTUnwrapSuccess(Attestation.make(
                mrSigner: try XCTUnwrap(Data(hexEncoded: Self.devMrSignerHex)),
                productId: McConstants.FOG_REPORT_PRODUCT_ID,
                minimumSecurityVersion: McConstants.FOG_REPORT_SECURITY_VERSION,
                allowedHardeningAdvisories: ["INTEL-SA-00334"]))
        }
    }
    private func defaultAttestation(mrEnclaveHex: String) throws -> Attestation {
        Attestation(mrEnclaves: [
            try XCTUnwrapSuccess(Attestation.MrEnclave.make(
                mrEnclave: try XCTUnwrap(Data(hexEncoded: mrEnclaveHex)),
                allowedHardeningAdvisories: ["INTEL-SA-00334"])),
        ])
    }

    func consensusTrustRoots() throws -> [NIOSSLCertificate] { try Self.trustRoots() }
    func fogTrustRoots() throws -> [NIOSSLCertificate] { try Self.trustRoots() }

    static func trustRoots() throws -> [NIOSSLCertificate] {
        let trustRootsBytes = try self.trustRootsBytes()
        return try trustRootsBytes.map { try NIOSSLCertificate(bytes: Array($0), format: .der) }
    }
    static func trustRootsBytes() throws -> [Data] {
        try Self.trustRootsB64.map { try XCTUnwrap(Data(base64Encoded: $0)) }
    }

    var consensusRequiresCredentials: Bool {
        switch self {
        case .mainNet, .testNet:
            return false
        case .alpha, .mobiledev, .master, .build, .demo, .diogenes, .drakeley, .eran:
            return false
        }
    }
    var consensusCredentials: BasicCredentials? {
        switch self {
        case .mainNet, .testNet:
            // No credentials necessary.
            return nil
        case .alpha, .mobiledev, .master, .build, .demo, .diogenes, .drakeley, .eran:
            return BasicCredentials(username: Self.devAuthUsername, password: Self.devAuthPassword)
        }
    }

    var fogRequiresCredentials: Bool {
        switch self {
        case .mainNet, .testNet:
            return false
        case .alpha, .mobiledev, .master, .build, .demo, .diogenes, .drakeley, .eran:
            return true
        }
    }
    var fogUserCredentials: BasicCredentials? {
        switch self {
        case .mainNet, .testNet:
            // No credentials necessary.
            return nil
        case .alpha, .mobiledev, .master, .build, .demo, .diogenes, .drakeley, .eran:
            return BasicCredentials(username: Self.devAuthUsername, password: Self.devAuthPassword)
        }
    }

    var invalidCredentials: BasicCredentials {
        BasicCredentials(username: Self.invalidCredUsername, password: Self.invalidCredPassword)
    }

#if canImport(Keys)
    private static let devAuthUsername = MobileCoinKeys().devNetworkAuthUsername
    private static let devAuthPassword = MobileCoinKeys().devNetworkAuthPassword
#else
    private static let devAuthUsername = ""
    private static let devAuthPassword = ""
#endif

    var testAccountsMnemonics: [String] {
        switch self {
        case .mainNet:
            return []

        case .testNet:
            return Self.testNetTestAccountMnemonicsCommaSeparated
                .split(separator: ",").map { String($0) }

        case .alpha, .mobiledev, .master, .build, .demo, .diogenes, .drakeley, .eran:
            return []
        }
    }

#if canImport(Keys)
    private static let testNetTestAccountMnemonicsCommaSeparated =
        MobileCoinKeys().testNetTestAccountMnemonicsCommaSeparated
#else
    private static let testNetTestAccountMnemonicsCommaSeparated = ""
#endif

    var testAccountsPrivateKeys:
        [(viewPrivateKey: RistrettoPrivate, spendPrivateKey: RistrettoPrivate)]
    {
        testAccountsPrivateKeysHex.map {
            (RistrettoPrivate(hexEncoded: $0.viewPrivateKeyHex)!,
             RistrettoPrivate(hexEncoded: $0.spendPrivateKeyHex)!)
        }
    }

    private var testAccountsPrivateKeysHex:
        [(viewPrivateKeyHex: String, spendPrivateKeyHex: String)]
    {
        switch self {
        case .mainNet:
            return []

        case .testNet:
            return []

        case .alpha, .mobiledev, .master, .build, .demo, .diogenes, .drakeley, .eran:
            return Self.devNetworkTestAccountPrivateKeysHex
        }
    }

}
