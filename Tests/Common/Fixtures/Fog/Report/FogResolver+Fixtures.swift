//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

extension FogResolver {
    enum Fixtures {}
}

extension FogResolver.Fixtures {
    struct Default {
        let fogResolver: FogResolver

        init() throws {
            self.fogResolver = try Self.fogResolver()
        }

        init(reportUrl: String?) throws {
            if let reportUrl = reportUrl {
                try self.init(reportUrl: FogUrl.make(string: reportUrl).get())
            } else {
                try self.init()
            }
        }

        init(reportUrl: FogUrl?) throws {
            if let reportUrl = reportUrl {
                self.fogResolver = try Self.fogResolver(reportUrl: reportUrl)
            } else {
                self.fogResolver = try Self.fogResolver()
            }
        }
    }
    
    struct TxOutMemo {
        let fogResolver: FogResolver

        init(reportUrl: String?) throws {
            guard let reportUrl = reportUrl else {
                throw InvalidInputError("URL Required for init()")
            }
            try self.init(reportUrl: FogUrl.make(string: reportUrl).get())
        }

        init(reportUrl: FogUrl?) throws {
            guard let reportUrl = reportUrl else {
                throw InvalidInputError("URL Required for init()")
            }
            self.fogResolver = try Self.fogResolver(reportUrl: reportUrl)
        }
    }
}

extension FogResolver.Fixtures.Default {

    private static func attestation() throws -> Attestation {
        try Attestation.Fixtures.Default().reportAttestation
    }

    private static func reportUrl() throws -> FogUrl {
        try FogUrl.make(string: AccountKey.Fixtures.Init().fogReportUrl).get()
    }

    fileprivate static func fogResolver() throws -> FogResolver {
        try fogResolver(reportUrl: self.reportUrl())
    }

    fileprivate static func fogResolver(reportUrl: FogUrl) throws -> FogResolver {
        FogResolver(
            attestation: try self.attestation(),
            reportUrlsAndResponses: [(reportUrl, try self.reportResponse())])
    }

    private static func reportResponse() throws -> Report_ReportResponse {
        let serializedReportResponse = try XCTUnwrap(Data(base64Encoded: self.reportResponseB64))
        return try Report_ReportResponse(serializedData: serializedReportResponse)
    }

}

extension FogResolver.Fixtures.Default {

    private static let reportResponseB64 = """
        CrceEqseCoMCCoACBZnRUaU3RR+I6ROk4HZL09IOO/FoIp361qNiGmpKPz2S6+yeVumrVT7YGQ7xlbLDdXlnppvbrt9\
        yQGUC0G12aejPL6PAVieHR1Xp9H8ubQbqaQYCD9YI4SeYuW8krHeiCpharc/oBlWDYjH43olpr8eYmj+U4ElaBQ7SJv\
        fvY2eQiE+jhXkMURIDk4/kOnc7FtzNXr5LeVn3Efv+WtyP1Jbm1dHy2TG0aOwPwP+fcc6XkT10ju+T2ZYWxoKwQDZR0\
        Y1/rHAU7MQtv1gEiwqmi0Uz8RsuJZ4jnTPGr9GDY5RvUxP5pgrwBk3BG8JzMyNJY71N5s1Uff63RjfPA3xLvxKlCTCC\
        BKEwggMJoAMCAQICCQDRB3ZdMqOwljANBgkqhkiG9w0BAQsFADB+MQswCQYDVQQGEwJVUzELMAkGA1UECAwCQ0ExFDA\
        SBgNVBAcMC1NhbnRhIENsYXJhMRowGAYDVQQKDBFJbnRlbCBDb3Jwb3JhdGlvbjEwMC4GA1UEAwwnSW50ZWwgU0dYIE\
        F0dGVzdGF0aW9uIFJlcG9ydCBTaWduaW5nIENBMB4XDTE2MTEyMjA5MzY1OFoXDTI2MTEyMDA5MzY1OFowezELMAkGA\
        1UEBhMCVVMxCzAJBgNVBAgMAkNBMRQwEgYDVQQHDAtTYW50YSBDbGFyYTEaMBgGA1UECgwRSW50ZWwgQ29ycG9yYXRp\
        b24xLTArBgNVBAMMJEludGVsIFNHWCBBdHRlc3RhdGlvbiBSZXBvcnQgU2lnbmluZzCCASIwDQYJKoZIhvcNAQEBBQA\
        DggEPADCCAQoCggEBAKl6LeDmbqYUfJ7nRawBYmhscZIJmvxLPwQPrW3gk1EddOgC9RDXFgOBV9yvhPQQS9P+1+a4+Z\
        yIF/0f9bm4ZClsPYH6jxtyngLSHXL/7kztcl7+dL6mj7xNQkQob83Uv2RAakOaFby0z2d1RInEI5crSoDfXC58W8Lbr\
        y1Cu3skT3yVv5LHXTsz/FQQZ4qJWJ0Qg9o6zEWfJwTNmVmMJ158GHjgB1flvbToQCJsEcChf/ecgLFcHdta8hzCQXBh\
        +9Ki2oGe07crfvqjv+vigFybisGao0ZRLUhM/IGUHhX1WIHMEn6PeqEjAM1a+1dC+h0gy0Z6W+scZmz3ajaJeLUCAwE\
        AAaOBpDCBoTAfBgNVHSMEGDAWgBR4Q3t2pn680K9+QjfrNXw7hwFRPDAOBgNVHQ8BAf8EBAMCBsAwDAYDVR0TAQH/BA\
        IwADBgBgNVHR8EWTBXMFWgU6BRhk9odHRwOi8vdHJ1c3RlZHNlcnZpY2VzLmludGVsLmNvbS9jb250ZW50L0NSTC9TR\
        1gvQXR0ZXN0YXRpb25SZXBvcnRTaWduaW5nQ0EuY3JsMA0GCSqGSIb3DQEBCwUAA4IBgQBnCLYbXCvSFUc+K0avmShP\
        u5OdPzsVLJlvGmrzsym9IgsdO2EPa84uZ1O97TBNshkS84UlYhbPy6RWvZaUC+iS9WkMJg0e+E8WBgQCIuX+COUyaAg\
        hKkR8/dZKRulL8p9rS5pyHSWzxOL2L1i67V13xQUkjw+AH5+/t/11IIAJXO6Ak4szn227ThZWAOIOSnGIEtSdmQHjEK\
        m1HWbHmQnGmWWZ+ubXannvFF2ZQ78dPjXTtC0fuaRcvo7jNMFm7ufTL83Jk1247Iux2Os3ed2KuStuOH8BR0UPHjgdC\
        FgfuD3zOxXgAKWb5X6pSjpS3GS9rslZs0ZMkeclu9rqPZnoV+OAojydn7HvWOnkLXHxITD5Jh1yNNbDfisD26QN/fsT\
        rErY4T/TdWNWtrUAFaPslYC4Fdh8LO9xXNKN8Au/KjxAPr9mkbPwXt2RQ4A8oIXP9X4FPuwvj+pG6neKaMm+iFvCgiW\
        8XzCb5KK3TToDlFMZ3TxxIv7W/1O7i4yzoDwSzwowggVLMIIDs6ADAgECAgkA0Qd2XTKjsJQwDQYJKoZIhvcNAQELBQ\
        AwfjELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAkNBMRQwEgYDVQQHDAtTYW50YSBDbGFyYTEaMBgGA1UECgwRSW50ZWwgQ\
        29ycG9yYXRpb24xMDAuBgNVBAMMJ0ludGVsIFNHWCBBdHRlc3RhdGlvbiBSZXBvcnQgU2lnbmluZyBDQTAgFw0xNjEx\
        MTQxNTM3MzFaGA8yMDQ5MTIzMTIzNTk1OVowfjELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAkNBMRQwEgYDVQQHDAtTYW5\
        0YSBDbGFyYTEaMBgGA1UECgwRSW50ZWwgQ29ycG9yYXRpb24xMDAuBgNVBAMMJ0ludGVsIFNHWCBBdHRlc3RhdGlvbi\
        BSZXBvcnQgU2lnbmluZyBDQTCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAJ88ZH61dzy7US0nMsDXQV67V\
        aD6nt4uZJGZ5oIduRDVMXc3CXdGampeR4bM0t3r1BSdai9jJVKd0QzJhzewd5waB+KcR6GuAElIR2xIn0WloV16yOzG\
        rMZFrbQ9h2ed9ZwJO8Wi6WlsVHhUG5eedUtXORS+VdMv9MCd3ychmTTNmQUns/ku14+/KSRqvstxJA7znC1xB7RHVFp\
        /+xDrBgpoqYWAIZ42kQlSaDiS1qXiqAgDGT5AdTFATjazFWI3maqCUHRAl1Si3+j1r9X+Yx4fwq84CJBvKKeQ2d2f4G\
        CTmxJXkMWAXQN99WqZUxuW3mneM+0ibMEgfRBCtcmrf0BPxxHA/kdp+5V4sdwOxGnqGiXg/5kUiG7yaZsjW7SEfdb/Q\
        LYG5hcHk8L7mLMUWH+c/SVzYt/qsQs70tl2c6GkvUTEU6r0f8Hy09DzhPdKBvicCJ8Nps23/O7oyYIajlTyXAQW0YxG\
        g5pfgBL73T3HTSViea3CwNVa/28GIkJdGwIDAQABo4HJMIHGMGAGA1UdHwRZMFcwVaBToFGGT2h0dHA6Ly90cnVzdGV\
        kc2VydmljZXMuaW50ZWwuY29tL2NvbnRlbnQvQ1JML1NHWC9BdHRlc3RhdGlvblJlcG9ydFNpZ25pbmdDQS5jcmwwHQ\
        YDVR0OBBYEFHhDe3amfrzQr35CN+s1fDuHAVE8MB8GA1UdIwQYMBaAFHhDe3amfrzQr35CN+s1fDuHAVE8MA4GA1UdD\
        wEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMA0GCSqGSIb3DQEBCwUAA4IBgQB4Xy1gxcgK9Cp5dhAhORXagsmy\
        nongkColpsdbFgkcaKsgSq5xGIlJLH4eMgkRRVqPwTRCMS53pjmU2ZeVyOpFdoI86orR4ZHPqGL6uKky09mwU1oHAtB\
        VX3TlIOMDMPM0gOetydfIHiBwMUK/AMUoqAtGM4H9YCqCxwNSgarllWLMtTNOqJA+ZQsBBoH1zo62LqycQUmIJDrskv\
        Jb8Tzf9+vMKY7lG7paNTi2aybLxFpR3gA8rTBlMa189dTvD4gF0bkTPSQTWrPEZBoviAg0nXMzKV4Odu5LxSJyMmKO+\
        oDXnZKrTj0RIPP7WtEZzY1USqHUpoZea1e+rFdxMH4uPLkHDaR7S/yIaeAUE+oJNUHeinkoEbdGNsXpFFLPDO5Z8vtA\
        Ss0LxYTLnINUBHNMDn7GYFzfzy/0ObbUcZ9wLw4MP6BP2xKmyyrRqxya8fj0w6CO3XKjKwu10K0lb/0Vmmg7KlofHRH\
        6YlMvA9dUyu8NpXNaHlqITH6J2RIYydcaqAh7Im5vbmNlIjoiNmY4ZDJhMjIxNjZjOGM3YjMyYWQyMzA5OGI4YmRjMm\
        QiLCJpZCI6IjIzMTEzMzE5OTAxNDQ3MzU0ODQ5MTA5MTEzNzg4NjczMzUyNzE2IiwidGltZXN0YW1wIjoiMjAyMS0wM\
        y0wM1QyMzoxNTozOS4zNDgxOTMiLCJ2ZXJzaW9uIjo0LCJlcGlkUHNldWRvbnltIjoiZzRjTDZ2bjZNOUlEVFBTcWhY\
        OFBmN1NyOStUN3o0Z0RvOUFTODVzUnRUemIvVHdObFhXaW5KdmMzMkNhTXlZeEJTNDdCYXNUMFgyOCtzWmN3aXZqVTR\
        WOSsrVW5Dc1hoSDhGTHhOZVd2SzhCNGNMVWtZQk90NEowOWNVS3ZGTGJQaGd0YVc1aEVESUo4VTFxcnAwMHJ4UWx2VU\
        NqREtHeFBacUZEeER0bFhBPSIsImFkdmlzb3J5VVJMIjoiaHR0cHM6Ly9zZWN1cml0eS1jZW50ZXIuaW50ZWwuY29tI\
        iwiYWR2aXNvcnlJRHMiOlsiSU5URUwtU0EtMDAzMzQiXSwiaXN2RW5jbGF2ZVF1b3RlU3RhdHVzIjoiU1dfSEFSREVO\
        SU5HX05FRURFRCIsImlzdkVuY2xhdmVRdW90ZUJvZHkiOiJBZ0FCQVA0TEFBQUxBQW9BQUFBQUFKYTYxRjVISzRYdU4\
        raHBVQW9zRkRVQUFBQUFBQUFBQUFBQUFBQUFBQUFBRVJFREJmK0FCZ0FBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQU\
        FBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUJ3QUFBQUFBQUFBSEFBQUFBQUFBQUU4MmFUNHBDUHFId0ZlRXdUdGZiQ\
        y8zaUsxRHNIWjU1WWEvRW5Zb3lWRnBBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFCKzVl\
        S2RkR0kvMjhiNzhVVkw1dk83QzRiQkkyYTN0SGl0RXpVK1JONkVFUUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUF\
        BQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQU\
        FBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBUUFBUUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQ\
        UFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBRGhXa0hrc0NwbVh0eXZMbUdqMWRj\
        dlRuR3NhWWJDdkVWaE9wNUR2YzR0Q0ZDUmwvc0VGY0tMaUN1RTU2UjNXeHg0TGplQ1Z3R3dCSW5VWWxySmR4VTUifRm\
        2BQAAAAAAABLTBjCCA08wggI3oAMCAQICAhAAMA0GCSqGSIb3DQEBCwUAMIGKMQswCQYDVQQGEwJVUzEWMBQGA1UEBw\
        wNU2FuIEZyYW5jaXNjbzETMBEGA1UECAwKQ2FsaWZvcm5pYTEVMBMGA1UECgwMVEVTVElORyBPTkxZMRAwDgYDVQQLD\
        AdURVNUSU5HMSUwIwYDVQQDDBxUZXN0IFBlbnVsdGltYXRlIEF1dGhvcml0eSAxMCAXDTIxMDIyMjE5MjQzMVoYDzIw\
        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\
        EdBeRD4XdjD6g9VlVaDFCFH4wzLbc+q9YeS1ehSpN6kLiU2AG5hhcp3Zd35LRrmWxeDtW8r+Aqg50gApEwlg6fREI5u\
        d0YmM9xGe5AMErCgbxUp1/MOyCFfwwYFk2L57wPh20ZFyN+9l13kShdC5qRYBUsfHXqW30v8+10tEDArTRmUyT1J/jP\
        r4Ssq+fb+K5aCqndHfXAK/NiTf5NlRPXa38mYEiDl3ehdoMr9iIcISxOF2gK0QUCfDJXX7XfSbVmt+twZ8qIynYO4lV\
        obkqjXz/DxxfVny6wLzR7v+woxiPwfPOWe7wYH641z9F+hCUZsDmQHw9zBdBAsFzD8CLDicCZ/5iiNADlv6DiGUL/lZ\
        B3WimtNc79yiub2q3g3ZDeUwEvsLMIIF9zCCA9+gAwIBAgIUaSsoeSlbM7p93RxClc6BCcifs64wDQYJKoZIhvcNAQE\
        LBQAwgYExCzAJBgNVBAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRYwFAYDVQQHDA1TYW4gRnJhbmNpc2NvMRUwEw\
        YDVQQKDAxURVNUSU5HIE9OTFkxEDAOBgNVBAsMB1RFU1RJTkcxHDAaBgNVBAMME1Rlc3QgUm9vdCBBdXRob3JpdHkwI\
        BcNMjEwMjIyMTkyNDMwWhgPMjA3MTAyMjIxOTI0MzBaMIGBMQswCQYDVQQGEwJVUzETMBEGA1UECAwKQ2FsaWZvcm5p\
        YTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzEVMBMGA1UECgwMVEVTVElORyBPTkxZMRAwDgYDVQQLDAdURVNUSU5HMRw\
        wGgYDVQQDDBNUZXN0IFJvb3QgQXV0aG9yaXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxABZ75QZv9\
        uH9/E823VTTmpWiOiehoqksZMqsDARqYdDexAQb1Y+qyT6Hlp5QMUHQlkomFKLnhe/0+wxZ1/uTqnhy2FRhrlclpOvc\
        zT10Smcx9RkKACpxCW095MWxeFwtMmLpqkXfl4KeMptxdHRASHuLlKL+FXwOqKw3J2nw5q2DpBsg1ONkdW4m55ZFdim\
        X3M7T/Wur5WlB+ntBpKFU/5T+rdD3OUm/tExbYk7C58XmYW08TnFR9JOMekFZMmTfl5d1ee3koyzz225QfNEupUJDVM\
        Xcg4whp826arxQIXrM2DfgwZnxFqS617dNsOPNjIoAYSEFPczYTw9WHR7O3UISnYwYvCsXxGwLZLXFkgUBM5GKItvEH\
        DbUh3C7ZjyM51A04EJg47G3nI1A6q9EVnmwGaZFxq8bJAzosn5zaSrbUA25hRff25C4BYNjydBI133PjSflLaGjnJYP\
        ruLO4XpzB3wszqKm3tiWN39sgC4sMWZfSlxlWox3SzY2XVl8Q9RqMO8LMUPNhwmTfpEXDW5+NqH+vMiH9UmnsiEwybF\
        che4sE23NJTeO2Xytt55VfoD2Gidte/Sqt5AJUPu6nfK8QloOCZ1N99MrpWpcZPHittqaYHZ5lWXHKthp/im672hXPl\
        8bNxMUoREqomZdD9mdj/P6w9zFeTkr7P9XQUCAwEAAaNjMGEwHQYDVR0OBBYEFAJRrW43FeYjYEbr1fMNsr2EgvYyMB\
        8GA1UdIwQYMBaAFAJRrW43FeYjYEbr1fMNsr2EgvYyMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMA0GC\
        SqGSIb3DQEBCwUAA4ICAQB5Y7v3j7d1o//LgeOxfA7veBpl4al9o625NMyh0FGhxA10oe5cL+LZktZOeWuqZhee3aQR\
        b4hmBi7bhIRYPW5/OvkR0HGlz5PSxm1pkrirJ03NQ8Rqct6eCWBXkzRGpvEltXfl9vRwsnUvuZ664WTyzQR3C+jP5Hr\
        87LPXJEFJ07JA0B7o52nG+AGq/r4HQAwFB8krdvwsFfs7OhY9zb0H3zpuIrgS6G656Oki3RfCtGfVdmntG6U3p+856Q\
        Sb9C8Eo3pYi1SPGBLIiWCh527DqRQPwJCPtzLp4L1dC5XUGGujO5RkuNYiJcZWTn8mu4JTl2aWu49EA6IatRvI0QnY2\
        S98H8TjIqdsKT8wjnsfBQAU32Se5wwQLiEcM6K/YL3zhON8kSMmqOVRfcavuyebaymSgTsOG1d2YB6Fy23CWqMmZKl2\
        j+8++Iy/1q11z+h8Gu7ViYf3qg3yVBWLxapXZJhMdacUbeJpzw+ULOF5gbHZ2ydYhgj+OquDKoVSuT3n2zsVycbAdb2\
        /q+PeH8JzsyTxuz2bmFoM5GyDL3KvYQGqZWxN0hA++D6Lk7mhof9ZNOJtaeh1vNN28AmVLgStwZ2XsvX8q0uDJrwijT\
        v/DLqXgeF0jtQ9O8hhoGO9+V0UwWmzx5a3MJ6LxBkbL2S5D9nUGYgaRPdJbRogT1klGxpAOnqPPFK8FtUR18j0SA5oe\
        BtZ+3WFdBoJb6f2z3O1JQah6gq3sA6DTKfugv4Gl5wNyvyycS1v6dp/77eLUlXMBw==
        """
    private static let reportPubkeyExpiry: UInt64 = 1462

}

extension FogResolver.Fixtures.TxOutMemo {

    private static func attestation() throws -> Attestation {
        try Attestation.Fixtures.Default().reportAttestation
    }

    fileprivate static func fogResolver(reportUrl: FogUrl) throws -> FogResolver {
        FogResolver(
            attestation: try self.attestation(),
            reportUrlsAndResponses: [(reportUrl, try self.reportResponse())])
    }

    private static func reportResponse() throws -> Report_ReportResponse {
        let serializedReportResponse = try XCTUnwrap(Data(hexEncoded: self.reportResponseHex))
        return try Report_ReportResponse(serializedData: serializedReportResponse)
    }

}

extension FogResolver.Fixtures.TxOutMemo {

    static let reportResponseHex =
            """
            0ab71e12ab1e0a83020a800272af3c371202876b401b70c477be1b72684c9055\
            2232012c83144e1c3682a23b7beb9313f0d601032c86ec251a7e23aaa2749f83\
            65f07af9c6631e53c253a854519b1ef903a0fef02853f2026de0531bdd4be21e\
            5f44d337f77603fca53aff4289928e0c857b1bbc84efd94467ce83ad6d46bbff\
            e167add76b3d074a9e12222a592e0d9eb8e27df1b960da2064edac4f907dab3f\
            b4f279d2a0f67c8910ad38148d752d11625318dc8c1f852d3c926b52a0c6ed37\
            528459f73524beb7290031bbbe0ef028d21ef286a6763006740de9ff7f0312ff\
            55e83f54c89274fec01078da692299a3deaea79fb6c461d2f066f4e7dc26cce9\
            d65bff638da48d451049b30612a509308204a130820309a003020102020900d1\
            07765d32a3b096300d06092a864886f70d01010b0500307e310b300906035504\
            0613025553310b300906035504080c0243413114301206035504070c0b53616e\
            746120436c617261311a3018060355040a0c11496e74656c20436f72706f7261\
            74696f6e3130302e06035504030c27496e74656c205347582041747465737461\
            74696f6e205265706f7274205369676e696e67204341301e170d313631313232\
            3039333635385a170d3236313132303039333635385a307b310b300906035504\
            0613025553310b300906035504080c0243413114301206035504070c0b53616e\
            746120436c617261311a3018060355040a0c11496e74656c20436f72706f7261\
            74696f6e312d302b06035504030c24496e74656c205347582041747465737461\
            74696f6e205265706f7274205369676e696e6730820122300d06092a864886f7\
            0d01010105000382010f003082010a0282010100a97a2de0e66ea6147c9ee745\
            ac0162686c7192099afc4b3f040fad6de093511d74e802f510d716038157dcaf\
            84f4104bd3fed7e6b8f99c8817fd1ff5b9b864296c3d81fa8f1b729e02d21d72\
            ffee4ced725efe74bea68fbc4d4244286fcdd4bf64406a439a15bcb4cf677544\
            89c423972b4a80df5c2e7c5bc2dbaf2d42bb7b244f7c95bf92c75d3b33fc5410\
            678a89589d1083da3acc459f2704cd99598c275e7c1878e00757e5bdb4e84022\
            6c11c0a17ff79c80b15c1ddb5af21cc2417061fbd2a2da819ed3b72b7efaa3bf\
            ebe2805c9b8ac19aa346512d484cfc81941e15f55881cc127e8f7aa12300cd5a\
            fb5742fa1d20cb467a5beb1c666cf76a368978b50203010001a381a43081a130\
            1f0603551d2304183016801478437b76a67ebcd0af7e4237eb357c3b8701513c\
            300e0603551d0f0101ff0404030206c0300c0603551d130101ff040230003060\
            0603551d1f045930573055a053a051864f687474703a2f2f7472757374656473\
            657276696365732e696e74656c2e636f6d2f636f6e74656e742f43524c2f5347\
            582f4174746573746174696f6e5265706f72745369676e696e6743412e63726c\
            300d06092a864886f70d01010b050003820181006708b61b5c2bd215473e2b46\
            af99284fbb939d3f3b152c996f1a6af3b329bd220b1d3b610f6bce2e6753bded\
            304db21912f385256216cfcba456bd96940be892f5690c260d1ef84f16060402\
            22e5fe08e5326808212a447cfdd64a46e94bf29f6b4b9a721d25b3c4e2f62f58\
            baed5d77c505248f0f801f9fbfb7fd752080095cee80938b339f6dbb4e165600\
            e20e4a718812d49d9901e310a9b51d66c79909c6996599fae6d76a79ef145d99\
            43bf1d3e35d3b42d1fb9a45cbe8ee334c166eee7d32fcdc9935db8ec8bb1d8eb\
            3779dd8ab92b6e387f0147450f1e381d08581fb83df33b15e000a59be57ea94a\
            3a52dc64bdaec959b3464c91e725bbdaea3d99e857e380a23c9d9fb1ef58e9e4\
            2d71f12130f9261d7234d6c37e2b03dba40dfdfb13ac4ad8e13fd3756356b6b5\
            0015a3ec9580b815d87c2cef715cd28df00bbf2a3c403ebf6691b3f05edd9143\
            803ca085cff57e053eec2f8fea46ea778a68c9be885bc28225bc5f309be4a2b7\
            4d3a03945319dd3c7122fed6ff53bb8b8cb3a03c12cf0a3082054b308203b3a0\
            03020102020900d107765d32a3b094300d06092a864886f70d01010b0500307e\
            310b3009060355040613025553310b300906035504080c024341311430120603\
            5504070c0b53616e746120436c617261311a3018060355040a0c11496e74656c\
            20436f72706f726174696f6e3130302e06035504030c27496e74656c20534758\
            204174746573746174696f6e205265706f7274205369676e696e672043413020\
            170d3136313131343135333733315a180f32303439313233313233353935395a\
            307e310b3009060355040613025553310b300906035504080c02434131143012\
            06035504070c0b53616e746120436c617261311a3018060355040a0c11496e74\
            656c20436f72706f726174696f6e3130302e06035504030c27496e74656c2053\
            4758204174746573746174696f6e205265706f7274205369676e696e67204341\
            308201a2300d06092a864886f70d01010105000382018f003082018a02820181\
            009f3c647eb5773cbb512d2732c0d7415ebb55a0fa9ede2e649199e6821db910\
            d53177370977466a6a5e4786ccd2ddebd4149d6a2f6325529dd10cc98737b077\
            9c1a07e29c47a1ae004948476c489f45a5a15d7ac8ecc6acc645adb43d87679d\
            f59c093bc5a2e9696c5478541b979e754b573914be55d32ff4c09ddf27219934\
            cd990527b3f92ed78fbf29246abecb71240ef39c2d7107b447545a7ffb10eb06\
            0a68a98580219e36910952683892d6a5e2a80803193e407531404e36b3156237\
            99aa825074409754a2dfe8f5afd5fe631e1fc2af3808906f28a790d9dd9fe060\
            939b125790c5805d037df56a99531b96de69de33ed226cc1207d1042b5c9ab7f\
            404fc711c0fe4769fb9578b1dc0ec469ea1a25e0ff9914886ef2699b235bb484\
            7dd6ff40b606e6170793c2fb98b314587f9cfd257362dfeab10b3bd2d97673a1\
            a4bd44c453aaf47fc1f2d3d0f384f74a06f89c089f0da6cdb7fceee8c9821a8e\
            54f25c0416d18c46839a5f8012fbdd3dc74d256279adc2c0d55aff6f0622425d\
            1b0203010001a381c93081c630600603551d1f045930573055a053a051864f68\
            7474703a2f2f7472757374656473657276696365732e696e74656c2e636f6d2f\
            636f6e74656e742f43524c2f5347582f4174746573746174696f6e5265706f72\
            745369676e696e6743412e63726c301d0603551d0e0416041478437b76a67ebc\
            d0af7e4237eb357c3b8701513c301f0603551d2304183016801478437b76a67e\
            bcd0af7e4237eb357c3b8701513c300e0603551d0f0101ff0404030201063012\
            0603551d130101ff040830060101ff020100300d06092a864886f70d01010b05\
            000382018100785f2d60c5c80af42a797610213915da82c9b29e89e0902a25a6\
            c75b16091c68ab204aae711889492c7e1e320911455a8fc13442312e77a63994\
            d99795c8ea4576823cea8ad1e191cfa862fab8a932d3d9b0535a0702d0555f74\
            e520e30330f33480e7adc9d7c81e20703142bf00c528a80b463381fd602a82c7\
            035281aae59562ccb5334ea8903e650b010681f5ce8eb62eac9c414988243aec\
            92f25bf13cdff7ebcc298ee51bba5a3538b66b26cbc45a51de003cad306531ad\
            7cf5d4ef0f8805d1b9133d24135ab3c4641a2f8808349d7333295e0e76ee4bc5\
            227232628efa80d79d92ab4e3d1120f3fb5ad119cd8d544aa1d4a6865e6b57be\
            ac5771307e2e3cb9070da47b4bfc8869e01413ea093541de8a792811b74636c5\
            e91452cf0cee59f2fb404acd0bc584cb9c835404734c0e7ec6605cdfcf2ff439\
            b6d4719f702f0e0c3fa04fdb12a6cb2ad1ab1c9af1f8f4c3a08edd72a32b0bb5\
            d0ad256ffd159a683b2a5a1f1d11fa62532f03d754caef0da5735a1e5a884c7e\
            89d91218c9d71aa8087b226e6f6e6365223a2264333762396563363333383262\
            65303633393062306131653164666433323033222c226964223a223630303931\
            3934373432333632313039323431373939333339333932383239373634303039\
            35222c2274696d657374616d70223a22323032312d30392d32315431323a3533\
            3a35322e373433333239222c2276657273696f6e223a342c2265706964507365\
            75646f6e796d223a226734634c36766e364d3949445450537168583850663753\
            72392b54377a3467446f3941533835735274547a622f54774e6c5857696e4a76\
            63333243614d7959784253343742617354305832382b735a637769766a557869\
            514b4558716f39577435615530457a6241774e6f44524c5543566a357467654b\
            565973627935617a54652b7951727152325173566c54584c6e786f6651587946\
            4b39455371455932332f676455424d79484a556b3d222c2261647669736f7279\
            55524c223a2268747470733a2f2f73656375726974792d63656e7465722e696e\
            74656c2e636f6d222c2261647669736f7279494473223a5b22494e54454c2d53\
            412d3030333334225d2c22697376456e636c61766551756f7465537461747573\
            223a2253575f48415244454e494e475f4e4545444544222c22697376456e636c\
            61766551756f7465426f6479223a224167414241424d4d4141414d4141734141\
            414141414a6136314635484b3458754e2b687055416f73464455414141414141\
            4141414141414141414141414141414552454442662b41426741414141414141\
            4141414141414141414141414141414141414141414141414141414141414141\
            4141414141414141414141414141414277414141414141414141484141414141\
            4141414150346c5249424635466f344736666c4143792b725838686870663272\
            6957716a77545936716158346e39414141414141414141414141414141414141\
            41414141414141414141414141414141414141414141414141422b35654b6464\
            47492f323862373855564c35764f37433462424932613374486974457a552b52\
            4e36454551414141414141414141414141414141414141414141414141414141\
            4141414141414141414141414141414141414141414141414141414141414141\
            4141414141414141414141414141414141414141414141414141414141414141\
            4141414141414141414141414141414141414141414141414141414141414141\
            4141414141514141514141414141414141414141414141414141414141414141\
            4141414141414141414141414141414141414141414141414141414141414141\
            41414141414141414141414141414141414141414141414141414e6f38675873\
            5276585251345a77782b6c6546387671724d6647636d5533684265737a307734\
            6572465a6b61367273532b34744551667077436a757269654e4c6142422f4f74\
            4e426a6a4a63392b30466838734e35227d19500a00000000000012d306308203\
            4f30820237a00302010202021000300d06092a864886f70d01010b050030818a\
            310b30090603550406130255533116301406035504070c0d53616e204672616e\
            636973636f3113301106035504080c0a43616c69666f726e6961311530130603\
            55040a0c0c54455354494e47204f4e4c593110300e060355040b0c0754455354\
            494e473125302306035504030c1c546573742050656e756c74696d6174652041\
            7574686f7269747920313020170d3231303232323139323432315a180f323037\
            31303232323139323432315a308185310b300906035504061302555331163014\
            06035504070c0d53616e204672616e636973636f3113301106035504080c0a43\
            616c69666f726e696131153013060355040a0c0c54455354494e47204f4e4c59\
            3110300e060355040b0c0754455354494e473120301e06035504030c17546573\
            74204c6561662043657274696669636174652031302a300506032b6570032100\
            0ac7b2b1db818b88c6d138f7aba211f9c17de3638e5648199586a51b50d458fe\
            a381b93081b630090603551d1304023000301106096086480186f84201010404\
            03020430303106096086480186f842010d042416224f70656e53534c2047656e\
            6572617465642054657374204365727469666963617465301d0603551d0e0416\
            04140e8780a9a304b7dfed747f8747bdf3e8df6376a2301f0603551d23041830\
            168014c5d22030773ad70a6a31e0177ee31c67fb1aae5d300e0603551d0f0101\
            ff0404030205e030130603551d25040c300a06082b06010505070304300d0609\
            2a864886f70d01010b050003820101001faae447a1ae9358071dce6086558e31\
            db54d8a8f18b6b82e8e77bac1f0ee89d0b268bf9b350f627d773e389ccb7f4d3\
            98ec5bd9f054c94a521c0cdc43058e1ee97f8d228c229e6af26a12982d52cc66\
            300b0b32f9c5b53ec71a2207ce585ddbe462c920f6e0fb3c94c74f4bf45aca0e\
            6bfd34b4f4341fc3355129899424dd54991bafa63953e0732ace70407aedd37f\
            6f03de228d6e65980621a52f924fd0c6cd0119dd77858e53588900fecfa61e72\
            0482601439df551d3b7fc245c8f4b586e5529dfcbf37204653e31be5e8f20db7\
            4400678a7fdb88ecc0eea6c4c28097a871744d171380d306cb0ea6fc751e576c\
            ce39a4eb864bcf476a0a7baa0d8914bf12f509308204f1308202d9a003020102\
            02021000300d06092a864886f70d01010b0500308181310b3009060355040613\
            0255533113301106035504080c0a43616c69666f726e69613116301406035504\
            070c0d53616e204672616e636973636f31153013060355040a0c0c5445535449\
            4e47204f4e4c593110300e060355040b0c0754455354494e47311c301a060355\
            04030c135465737420526f6f7420417574686f726974793020170d3231303232\
            323139323432315a180f32303731303232323139323432315a30818a310b3009\
            0603550406130255533116301406035504070c0d53616e204672616e63697363\
            6f3113301106035504080c0a43616c69666f726e696131153013060355040a0c\
            0c54455354494e47204f4e4c593110300e060355040b0c0754455354494e4731\
            25302306035504030c1c546573742050656e756c74696d61746520417574686f\
            72697479203130820122300d06092a864886f70d01010105000382010f003082\
            010a02820101009beec250ba1e7f1d6499cdbde2d68e93b104ab2d72a1722429\
            4f4e701fe4417ae877e89d35d041a6f1fc27369d395faa21203368c3ebb92ffe\
            acb313b2232232a45e1d2523e0d714f74bac71b3ed3451ebcf02da9609bd9dde\
            d626073e92d1f6ec23e777aaeec1bdd283d9f61ccac8a14e284c95bfcfdbe581\
            16d148190dbe62b269e389a202a83a035c40ad2486e294dd9973694a363a3196\
            08dec8ec52d6bd5691c38c7b176acee387e66a75ffd849e9f2882342606e4616\
            0c6a44787d61c7d8a05b88734c83655ea4b078124b1c889d2639c0db70ad1d5c\
            2f9297559f4e12e220355a178b5eda40aa8ca3b2f2b916ddd2352e84bd6a2b83\
            bb2578567bbd6b0203010001a3663064301d0603551d0e04160414c5d2203077\
            3ad70a6a31e0177ee31c67fb1aae5d301f0603551d23041830168014c21f83a0\
            a3b6e83ee81114568d8cd134ef84113230120603551d130101ff040830060101\
            ff020100300e0603551d0f0101ff040403020186300d06092a864886f70d0101\
            0b050003820201003c724814866b51e346bb68adce2f05896a3db4e8375506d0\
            3a1d95a606087708ca92a8a2398c26df971d91f9a1ab87540681c27c36994a6f\
            34cc3340422bc349f0b59de68530d539d74ba2c5c416ad1471b3e74b9a99ce1c\
            79aa905d3cb1d9be70036f5ddda11670563fb5ea8fd1f9cb5992c02fafdd1f55\
            0217315bdf0f8f4bd50011bc0be9735a035b6233676a1c0aee39439e72ef221b\
            a7a0242e47a6ed328e4f5bab0baf12ca6d3fccf9d9fdf197a7e3ec58f18e6da0\
            c70be387450ba8395da398fcbd995527a62196f2b2c3ce5e20a6cc0ac7025f6e\
            17b92b017f12360f76860b783e27f82328f84babb3e623255b09f693973aac79\
            6fc478da8318108538783f9b0f9c306280d8702546be7ef85677f17a13e559b8\
            acd62fd763cbdc50f2eb69cd1f0f3458b0cfebe3fc539c97252c6f0d83d8a4f8\
            e7bef98d8734368aa64298ec4128d280077c984f21dd31e26c31ad965f719f75\
            c0bc07cd51d2855d7c1805e73c24591b4f670698335c830e7d84f1f672dc2d45\
            212046dee93328e37b01b3e6034a9917e77d83ba1d2f99a47824396903ee8cdf\
            6d0e72ebc02fd912ecb6f34841b22039a1afa492a91dcae17413eee1bc9a1f84\
            603d851b9b953492450619146e575d10deab1520d11c27e15f25bb573d0f2946\
            e464cfb79e44d2dbb31f88bf2ef02b4a7e5c60974c76ab7ac601293ac18b4250\
            e90685bdfdd9800012fb0b308205f7308203dfa00302010202145d7234090cbe\
            808d54640f7fd82a974b3adf90df300d06092a864886f70d01010b0500308181\
            310b30090603550406130255533113301106035504080c0a43616c69666f726e\
            69613116301406035504070c0d53616e204672616e636973636f311530130603\
            55040a0c0c54455354494e47204f4e4c593110300e060355040b0c0754455354\
            494e47311c301a06035504030c135465737420526f6f7420417574686f726974\
            793020170d3231303232323139323432305a180f323037313032323231393234\
            32305a308181310b30090603550406130255533113301106035504080c0a4361\
            6c69666f726e69613116301406035504070c0d53616e204672616e636973636f\
            31153013060355040a0c0c54455354494e47204f4e4c593110300e060355040b\
            0c0754455354494e47311c301a06035504030c135465737420526f6f74204175\
            74686f7269747930820222300d06092a864886f70d01010105000382020f0030\
            82020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0ec47ae14\
            211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940ab4c96425\
            78760779840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c94552d7ef\
            a081a56ad612dec932812676ebec091f2aed69123604f4888a125e04ff85f5a7\
            27c286664378581cf34c7ee13eb01cc4faf3308ed3c07a9415f98e5fbfe073e6\
            c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37bfdd62d75\
            816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623\
            c893eb0fba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781ac\
            a45bc02b1456b454231d2f2ed4ca6614e5242c7d7af0fe61e9af6ecfa76674ff\
            bc29b858091cbfb4011538f0e894ce45d21d7fac04ba2ff57e9ff6db21e2afd9\
            468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa84450b8c350\
            c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a36a9ec708\
            320ea42089991551f2656ec62ea38233946b85616ff182cf17cd227e596329b5\
            46ea04d13b053be4cf3338de777b50bc6eca7a6185cf7a5022bc9be3749b1bb4\
            3e10ecc88a0c580f2b7373138ee49c7bafd8be6a64048887230480b0c85a0452\
            55494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779a9e05539\
            5078d0b07286f9930203010001a3633061301d0603551d0e04160414c21f83a0\
            a3b6e83ee81114568d8cd134ef841132301f0603551d23041830168014c21f83\
            a0a3b6e83ee81114568d8cd134ef841132300f0603551d130101ff0405300301\
            01ff300e0603551d0f0101ff040403020186300d06092a864886f70d01010b05\
            000382020100818eb091ac31b10e66ae0f16def94939b46af53b06aae186f23d\
            38cd5a5212678929147da2096b6b9ae08f8aacd465357bce9a7943f8d47622e1\
            14fe8b6d2b649244121b27c866a2e212f5dc75e95b13859ed5ea6171425db03e\
            74e3fe0d4e1ff98d05f43eb2813ca3403fa715f7de2cde1fff2f9530f0289d4d\
            d67b0aac4075f9bc23bab5ffcc0dd20eee8280cae1c6269882ac6104b9979af7\
            c261646ee7a115188c83519f09ea63b1101eba71eb78c9094b9969ed5e5c5cad\
            09f84e1a1b62f1494a86ef661731348d339307fef746fa9f000fb8bf75447186\
            785aa658d16d19aaeaa6004ea362b52477bcd896594f62ea12360822cfa16d90\
            82feb6ada16079aae3249a87fcb89332939eea5915bd967ee96a0d2e57d37682\
            76546eb927d04f5fc45569d1bc3554caa0a61a5a648d9a6816e16886bc76db80\
            4830c959c0574094d287f8211d157775ead6f84dc6e2ca6017cea22449bc6f6f\
            bb19f3f315e4fd9734f42f7c3bd31a809277303ece15baad308b2bc3738efaa7\
            8a5f215f8eb6e93f55471a15593ae93dfb69cabc1e4e49cf8be15b585d0e2ffc\
            804f16a78bf7e1d0d4715e63fa686c911e57c5f6e4bc73703a27c55c9e3ccdb9\
            bbe9273a50654f55e6298ad321e20f02a8dfc47c98541c60e7e311ab0e1b32fc\
            4454fb270e1e9d36218da99d0c150691c23a36a529a2e00fe049f0ab85e3efa4\
            6153809be2a51a40dc98f56ad6675e8ed0c0fbe97703c3d7456ab4f0e0b126d1\
            60db1347297a2029ebc65d84b545dbe069e0a4c355db78d2b2f8d93c42b6ade3\
            1c9bf61d3e869a01
            """

//    private static let reportPubkeyExpiry: UInt64 = 1462

}

