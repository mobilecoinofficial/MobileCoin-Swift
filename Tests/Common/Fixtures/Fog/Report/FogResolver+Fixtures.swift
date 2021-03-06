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
