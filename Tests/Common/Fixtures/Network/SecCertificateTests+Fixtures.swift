//
//  Copyright (c) 2023-2024 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

enum SecCertificateTests {
    enum Fixtures {}

    static func createChain(_ chainAsDerBytesBase64: [String]) throws -> [SecCertificate] {
        try chainAsDerBytesBase64.map({ certBase64 in
            guard
                let data = Data(base64Encoded: certBase64),
                let cert = SecCertificateCreateWithData(nil, data as CFData)
            else {
                throw SSLTrustError("Bad data, cannot create SecCertificate")
            }
            return cert
        })
    }

    static func createSecTrust(_ certificateChain: [SecCertificate]) throws -> SecTrust {
        var secTrust: SecTrust?
        guard
            SecTrustCreateWithCertificates(
                certificateChain as AnyObject,
                SecPolicyCreateBasicX509(),
                &secTrust
            ) == errSecSuccess,
            let serverTrust = secTrust
        else {
            throw SSLTrustError("Cannot create SecTrust from Server Certificates")
        }

        return serverTrust
    }

    static func createCertificate(_ certificateAsDerBytesBase64: String) throws -> SecCertificate {
        guard
            let data = Data(base64Encoded: certificateAsDerBytesBase64),
            let cert = SecCertificateCreateWithData(nil, data as CFData)
        else {
            throw SSLTrustError("Bad data, cannot create SecCertificate")
        }
        return cert
    }

    static func keysFromCertificates(_ certificates: [SecCertificate]) throws -> [SecKey] {
        try certificates.map { certificate in
            try certificate.asPublicKey().get()
        }
    }
}

extension SecCertificateTests.Fixtures {
    struct TestNet {
        let certificateChain: [SecCertificate]
        let secTrust: SecTrust
        let validIntermediate: SecCertificate

        init() throws {
            let certChain = try SecCertificateTests.createChain(Self.chainAsDerBytesBase64)
            self.certificateChain = certChain
            self.secTrust = try SecCertificateTests.createSecTrust(certChain)
            self.validIntermediate = try SecCertificateTests.createCertificate(
                Self.intermediateCertificateBase64
            )
        }
    }

    struct AlphaNet {
        let certificateChain: [SecCertificate]
        let secTrust: SecTrust
        let validIntermediate: SecCertificate
        let wrongIntermediate: SecCertificate

        init() throws {
            let certChain = try SecCertificateTests.createChain(Self.chainAsDerBytesBase64)
            self.certificateChain = certChain
            self.secTrust = try SecCertificateTests.createSecTrust(certChain)
            self.validIntermediate = try SecCertificateTests.createCertificate(
                Self.intermediateCertificateBase64
            )
            self.wrongIntermediate = try SecCertificateTests.createCertificate(
                Self.wrongIntermediateCertificateBase64
            )
        }
    }
}

extension SecCertificateTests.Fixtures.TestNet {
    static var chainAsDerBytesBase64: [String] {
        [
        """
        MIIFMzCCBBugAwIBAgISBI/aO+hLqLodae+7N4tJsSU5MA0GCSqGSIb3DQEBCwUAMDIxCzAJBgNVBAYT\
        AlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQswCQYDVQQDEwJSMzAeFw0yMzAyMDcxNjU2MDBaFw0y\
        MzA1MDgxNjU1NTlaMCIxIDAeBgNVBAMTF2ZvZy50ZXN0Lm1vYmlsZWNvaW4uY29tMIIBIjANBgkqhkiG\
        9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxLjageuy3ryHbevK8g/Myf7W8iBDOsN6RJolSpOYKKniD56X+25J\
        3DdsFpXbeB0cFrdQOBcF9lW9CDPE/Jmqy3H1AVQKEgWy7a6sIEOCTeUAVZPLom9W4ocG08ndhgvq2IhY\
        yvpkRP2QuT7OofE98ICAQLqaDrjGYRT1VnN03GBQORFgYsvuKKGEUx87skwTzHlxHHD90IEojCVv8FcT\
        Ot0c0Vrtf5OMi5Z+9iRqc0xuQAKFF6RLRyLGd/koMaKdb+wUrcim3y6c5yHvx6/yLYl9F4Fzw8IJi34H\
        BDkqvL6EraELB2TOH1HLDYunkfPdH5ncnUdDpUNx9J6cYt995wIDAQABo4ICUTCCAk0wDgYDVR0PAQH/\
        BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMB0GA1UdDgQW\
        BBR/EOJh6X9bbKQqXUOMphagg1b1RTAfBgNVHSMEGDAWgBQULrMXt1hWy65QCUDmH6+dixTCxjBVBggr\
        BgEFBQcBAQRJMEcwIQYIKwYBBQUHMAGGFWh0dHA6Ly9yMy5vLmxlbmNyLm9yZzAiBggrBgEFBQcwAoYW\
        aHR0cDovL3IzLmkubGVuY3Iub3JnLzAiBgNVHREEGzAZghdmb2cudGVzdC5tb2JpbGVjb2luLmNvbTBM\
        BgNVHSAERTBDMAgGBmeBDAECATA3BgsrBgEEAYLfEwEBATAoMCYGCCsGAQUFBwIBFhpodHRwOi8vY3Bz\
        LmxldHNlbmNyeXB0Lm9yZzCCAQMGCisGAQQB1nkCBAIEgfQEgfEA7wB2AHoyjFTYty22IOo44FIe6YQW\
        cDIThU070ivBOlejUutSAAABhi0FMGcAAAQDAEcwRQIhAPyrKGUlGWYhfmGUvaYm687wivltAwKOLpZQ\
        AtA4D3iSAiBEFKrOvaLYXImQiM5FQqkKlLLT4urHPmqehTrOMk5gRwB1AK33vvp8/xDIi509nB4+GGq0\
        Zyldz7EMJMqFhjTr3IKKAAABhi0FMHYAAAQDAEYwRAIgPc+N1+C4lEHM1BwTFWi5O5/PdjpquYeL612C\
        Ognj0fICICO+NojMlspAduOOFqYQqGPhGwiixYTsNLtJ/SpvzUD9MA0GCSqGSIb3DQEBCwUAA4IBAQBN\
        9XQgZ4tmLkTLiqCohEavdw3IqSd6SHFXps5WDtoLa6iwFLz8wzZ/o+bOy9YrH3TNGgEXNUAdIQM3myTj\
        A16s9/MqwQfnPN4v7/mnHyzi57m0vkBU4oGv5+LdVVMN28OzdRxtqtKMPb23xI5dQwOx/cC9QYzCilpC\
        VqVes1I/OWXgCvaBGM6o7ob3u/JWoXKTsA4a8ZAvm5iaTdj98CbIyEljTs5bH+s0imsKVLUIp0AQ5MTN\
        AKUJIwP+9kmDQwkuXL/kBMmySC80Ok1Oz3MRtJdlg5coYzEIl9FYpR7EIJKjwjNwtQ980voFITHlIdqT\
        TWOjY6LvIhHg/J8RQl9f
        """,
        """
        MIIFFjCCAv6gAwIBAgIRAJErCErPDBinU/bWLiWnX1owDQYJKoZIhvcNAQELBQAwTzELMAkGA1UEBhMC\
        VVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2VhcmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JH\
        IFJvb3QgWDEwHhcNMjAwOTA0MDAwMDAwWhcNMjUwOTE1MTYwMDAwWjAyMQswCQYDVQQGEwJVUzEWMBQG\
        A1UEChMNTGV0J3MgRW5jcnlwdDELMAkGA1UEAxMCUjMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK\
        AoIBAQC7AhUozPaglNMPEuyNVZLD+ILxmaZ6QoinXSaqtSu5xUyxr45r+XXIo9cPR5QUVTVXjJ6oojkZ\
        9YI8QqlObvU7wy7bjcCwXPNZOOftz2nwWgsbvsCUJCWH+jdxsxPnHKzhm+/b5DtFUkWWqcFTzjTIUu61\
        ru2P3mBw4qVUq7ZtDpelQDRrK9O8ZutmNHz6a4uPVymZ+DAXXbpyb/uBxa3Shlg9F8fnCbvxK/eG3MHa\
        cV3URuPMrSXBiLxgZ3Vms/EY96Jc5lP/Ooi2R6X/ExjqmAl3P51T+c8B5fWmcBcUr2Ok/5mzk53cU6cG\
        /kiFHaFpriV1uxPMUgP17VGhi9sVAgMBAAGjggEIMIIBBDAOBgNVHQ8BAf8EBAMCAYYwHQYDVR0lBBYw\
        FAYIKwYBBQUHAwIGCCsGAQUFBwMBMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFBQusxe3WFbL\
        rlAJQOYfr52LFMLGMB8GA1UdIwQYMBaAFHm0WeZ7tuXkAXOACIjIGlj26ZtuMDIGCCsGAQUFBwEBBCYw\
        JDAiBggrBgEFBQcwAoYWaHR0cDovL3gxLmkubGVuY3Iub3JnLzAnBgNVHR8EIDAeMBygGqAYhhZodHRw\
        Oi8veDEuYy5sZW5jci5vcmcvMCIGA1UdIAQbMBkwCAYGZ4EMAQIBMA0GCysGAQQBgt8TAQEBMA0GCSqG\
        SIb3DQEBCwUAA4ICAQCFyk5HPqP3hUSFvNVneLKYY611TR6WPTNlclQtgaDqw+34IL9fzLdwALduO/Ze\
        lN7kIJ+m74uyA+eitRY8kc607TkC53wlikfmZW4/RvTZ8M6UK+5UzhK8jCdLuMGYL6KvzXGRSgi3yLgj\
        ewQtCPkIVz6D2QQzCkcheAmCJ8MqyJu5zlzyZMjAvnnAT45tRAxekrsu94sQ4egdRCnbWSDtY7kh+BIm\
        lJNXoB1lBMEKIq4QDUOXoRgffuDghje1WrG9ML+Hbisq/yFOGwXD9RiX8F6sw6W4avAuvDszue5L3sz8\
        5K+EC4Y/wFVDNvZo4TYXao6Z0f+lQKc0t8DQYzk1OXVu8rp2yJMC6alLbBfODALZvYH7n7do1AZls4I9\
        d1P4jnkDrQoxB3UqQ9hVl3LEKQ73xF1OyK5GhDDX8oVfGKF5u+decIsH4YaTw7mP3GFxJSqv3+0lUFJo\
        i5Lc5da149p90IdshCExroL1+7mryIkXPeFM5TgO9r0rvZaBFOvV2z0gp35Z0+L4WPlbuEjN/lxPFin+\
        HlUjr8gRsI3qfJOQFy/9rKIJR0Y/8Omwt/8oTWgy1mdeHmmjk7j1nYsvC9JSQ6ZvMldlTTKB3zhThV1+\
        XWYp6rjd5JW1zbVWEkLNxE7GJThEUG3szgBVGP7pSWTUTsqXnLRbwHOoq7hHwg==
        """,
        """
        MIIFYDCCBEigAwIBAgIQQAF3ITfU6UK47naqPGQKtzANBgkqhkiG9w0BAQsFADA/MSQwIgYDVQQKExtE\
        aWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMTDkRTVCBSb290IENBIFgzMB4XDTIxMDEy\
        MDE5MTQwM1oXDTI0MDkzMDE4MTQwM1owTzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNl\
        Y3VyaXR5IFJlc2VhcmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwggIiMA0GCSqGSIb3DQEB\
        AQUAA4ICDwAwggIKAoICAQCt6CRz9BQ385ueK1coHIe+3LffOJCMbjzmV6B493XCov71am72AE8o295o\
        hmxEk7axY/0UEmu/H9LqMZshftEzPLpI9d1537O4/xLxIZpLwYqGcWlKZmZsj348cL+tKSIG8+TA5oCu\
        4kuPt5l+lAOf00eXfJlII1PoOK5PCm+DLtFJV4yAdLbaL9A4jXsDcCEbdfIwPPqPrt3aY6vrFk/CjhFL\
        fs8L6P+1dy70sntK4EwSJQxwjQMpoOFTJOwT2e4ZvxCzSow/iaNhUd6shweU9GNx7C7ib1uYgeGJXDR5\
        bHbvO5BieebbpJovJsXQEOEO3tkQjhb7t/eo98flAgeYjzYIlefiN5YNNnWe+w5ysR2bvAP5SQXYgd0F\
        tCrWQemsAXaVCg/Y39W9Eh81LygXbNKYwagJZHduRze6zqxZXmidf3LWicUGQSk+WT7dJvUkyRGnWqNM\
        QB9GoZm1pzpRboY7nn1ypxIFeFntPlF4FQsDj43QLwWyPntKHEtzBRL8xurgUBN8Q5N0s8p0544fAQjQ\
        MNRbcTa0B7rBMDBcSLeCO5imfWCKoqMpgsy6vYMEG6KDA0Gh1gXxG8K28Kh8hjtGqEgqiNx2mna/H2ql\
        PRmP6zjzZN7IKw0KKP/32+IVQtQi0Cdd4Xn+GOdwiK1O5tmLOsbdJ1Fu/7xk9TNDTwIDAQABo4IBRjCC\
        AUIwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwSwYIKwYBBQUHAQEEPzA9MDsGCCsGAQUF\
        BzAChi9odHRwOi8vYXBwcy5pZGVudHJ1c3QuY29tL3Jvb3RzL2RzdHJvb3RjYXgzLnA3YzAfBgNVHSME\
        GDAWgBTEp7Gkeyxx+tvhS5B1/8QVYIWJEDBUBgNVHSAETTBLMAgGBmeBDAECATA/BgsrBgEEAYLfEwEB\
        ATAwMC4GCCsGAQUFBwIBFiJodHRwOi8vY3BzLnJvb3QteDEubGV0c2VuY3J5cHQub3JnMDwGA1UdHwQ1\
        MDMwMaAvoC2GK2h0dHA6Ly9jcmwuaWRlbnRydXN0LmNvbS9EU1RST09UQ0FYM0NSTC5jcmwwHQYDVR0O\
        BBYEFHm0WeZ7tuXkAXOACIjIGlj26ZtuMA0GCSqGSIb3DQEBCwUAA4IBAQAKcwBslm7/DlLQrt2M51oG\
        rS+o44+/yQoDFVDC5WxCu2+b9LRPwkSICHXM6webFGJueN7sJ7o5XPWioW5WlHAQU7G75K/QosMrAdSW\
        9MUgNTP52GE24HGNtLi1qoJFlcDyqSMo59ahy2cI2qBDLKobkx/J3vWraV0T9VuGWCLKTVXkcGdtwlfF\
        RjlBz4pYg1htmf5X6DYO8A4jqv2Il9DjXA6USbW1FzXSLr9Ohe8Y4IWS6wY7bCkjCWDcRQJMEhg76fsO\
        3txE+FiYruq9RUWhiF1myv4Q6W+CyBFCDfvp7OOGAN6dEOM4+qR9sdjoSYKEBpsr6GtPAQw4dy753ec5
        """,
        ]
    }

    static var intermediateCertificateBase64: String {
        """
        MIIFFjCCAv6gAwIBAgIRAJErCErPDBinU/bWLiWnX1owDQYJKoZIhvcNAQELBQAwTzELMAkGA1UEBhMC\
        VVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2VhcmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JH\
        IFJvb3QgWDEwHhcNMjAwOTA0MDAwMDAwWhcNMjUwOTE1MTYwMDAwWjAyMQswCQYDVQQGEwJVUzEWMBQG\
        A1UEChMNTGV0J3MgRW5jcnlwdDELMAkGA1UEAxMCUjMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK\
        AoIBAQC7AhUozPaglNMPEuyNVZLD+ILxmaZ6QoinXSaqtSu5xUyxr45r+XXIo9cPR5QUVTVXjJ6oojkZ\
        9YI8QqlObvU7wy7bjcCwXPNZOOftz2nwWgsbvsCUJCWH+jdxsxPnHKzhm+/b5DtFUkWWqcFTzjTIUu61\
        ru2P3mBw4qVUq7ZtDpelQDRrK9O8ZutmNHz6a4uPVymZ+DAXXbpyb/uBxa3Shlg9F8fnCbvxK/eG3MHa\
        cV3URuPMrSXBiLxgZ3Vms/EY96Jc5lP/Ooi2R6X/ExjqmAl3P51T+c8B5fWmcBcUr2Ok/5mzk53cU6cG\
        /kiFHaFpriV1uxPMUgP17VGhi9sVAgMBAAGjggEIMIIBBDAOBgNVHQ8BAf8EBAMCAYYwHQYDVR0lBBYw\
        FAYIKwYBBQUHAwIGCCsGAQUFBwMBMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFBQusxe3WFbL\
        rlAJQOYfr52LFMLGMB8GA1UdIwQYMBaAFHm0WeZ7tuXkAXOACIjIGlj26ZtuMDIGCCsGAQUFBwEBBCYw\
        JDAiBggrBgEFBQcwAoYWaHR0cDovL3gxLmkubGVuY3Iub3JnLzAnBgNVHR8EIDAeMBygGqAYhhZodHRw\
        Oi8veDEuYy5sZW5jci5vcmcvMCIGA1UdIAQbMBkwCAYGZ4EMAQIBMA0GCysGAQQBgt8TAQEBMA0GCSqG\
        SIb3DQEBCwUAA4ICAQCFyk5HPqP3hUSFvNVneLKYY611TR6WPTNlclQtgaDqw+34IL9fzLdwALduO/Ze\
        lN7kIJ+m74uyA+eitRY8kc607TkC53wlikfmZW4/RvTZ8M6UK+5UzhK8jCdLuMGYL6KvzXGRSgi3yLgj\
        ewQtCPkIVz6D2QQzCkcheAmCJ8MqyJu5zlzyZMjAvnnAT45tRAxekrsu94sQ4egdRCnbWSDtY7kh+BIm\
        lJNXoB1lBMEKIq4QDUOXoRgffuDghje1WrG9ML+Hbisq/yFOGwXD9RiX8F6sw6W4avAuvDszue5L3sz8\
        5K+EC4Y/wFVDNvZo4TYXao6Z0f+lQKc0t8DQYzk1OXVu8rp2yJMC6alLbBfODALZvYH7n7do1AZls4I9\
        d1P4jnkDrQoxB3UqQ9hVl3LEKQ73xF1OyK5GhDDX8oVfGKF5u+decIsH4YaTw7mP3GFxJSqv3+0lUFJo\
        i5Lc5da149p90IdshCExroL1+7mryIkXPeFM5TgO9r0rvZaBFOvV2z0gp35Z0+L4WPlbuEjN/lxPFin+\
        HlUjr8gRsI3qfJOQFy/9rKIJR0Y/8Omwt/8oTWgy1mdeHmmjk7j1nYsvC9JSQ6ZvMldlTTKB3zhThV1+\
        XWYp6rjd5JW1zbVWEkLNxE7GJThEUG3szgBVGP7pSWTUTsqXnLRbwHOoq7hHwg==
        """
    }
}

extension SecCertificateTests.Fixtures.AlphaNet {
    static var chainAsDerBytesBase64: [String] {
        [
        """
        MIIGwzCCBKugAwIBAgIQfvTrlw7IRAvSfeOyMujdkDANBgkqhkiG9w0BAQwFADBLMQswCQYDVQQGEwJB\
        VDEQMA4GA1UEChMHWmVyb1NTTDEqMCgGA1UEAxMhWmVyb1NTTCBSU0EgRG9tYWluIFNlY3VyZSBTaXRl\
        IENBMB4XDTIzMDMxNjAwMDAwMFoXDTIzMDYxNDIzNTk1OVowLzEtMCsGA1UEAxMkZm9nLmFscGhhLmRl\
        dmVsb3BtZW50Lm1vYmlsZWNvaW4uY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvn1V\
        OEDCaHwPEBBmpI7R4zvL/KQtJ/qqeyyZdQynSD3000xSCNqNzrxt2YTc1gAImbjYFgEqSggVZxcXdYQm\
        WkHQkC0gFMikmDPa1p7O35nbuSn4FGo1eT6zp5TVoq/ih9tjcs+NTiVwHQi6WeJ+YQF80EkeNyWwVS6t\
        ySoFZxH49shiufK1Q3L+qhKyaHH0NhLfj1h+YQhz6iUzhjL9oEDSGFQnRrYG/7qgktBBX9H4ANMzwN26\
        lFsaRkOePuDWhyfbLBvjDxBWt1ghP3v9m42BZGW6/WlxoTw5dWTOxYoFesTEIerq2hAJVM5WlH1AYcCA\
        zKDmTLmL2I+Y3BeuxQIDAQABo4ICvTCCArkwHwYDVR0jBBgwFoAUyNl4aKLZGWjVPXLeXwo+3LWGhqYw\
        HQYDVR0OBBYEFPIgDa6mPe1E3Zen+1yzjcN9evlaMA4GA1UdDwEB/wQEAwIFoDAMBgNVHRMBAf8EAjAA\
        MB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjBJBgNVHSAEQjBAMDQGCysGAQQBsjEBAgJOMCUw\
        IwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20vQ1BTMAgGBmeBDAECATCBiAYIKwYBBQUHAQEE\
        fDB6MEsGCCsGAQUFBzAChj9odHRwOi8vemVyb3NzbC5jcnQuc2VjdGlnby5jb20vWmVyb1NTTFJTQURv\
        bWFpblNlY3VyZVNpdGVDQS5jcnQwKwYIKwYBBQUHMAGGH2h0dHA6Ly96ZXJvc3NsLm9jc3Auc2VjdGln\
        by5jb20wggEEBgorBgEEAdZ5AgQCBIH1BIHyAPAAdwCt9776fP8QyIudPZwePhhqtGcpXc+xDCTKhYY0\
        69yCigAAAYbrbdVsAAAEAwBIMEYCIQDXuliv7iUwltczDlUnm7MrwhODr+uxbUOjByi/2vd1nwIhAOkr\
        mARJa0JrGN77yb8a7TX0O3uJmpEaALCL6jStUvdAAHUAejKMVNi3LbYg6jjgUh7phBZwMhOFTTvSK8E6\
        V6NS61IAAAGG623VzgAABAMARjBEAiAEDHD2O1dPo2jx7clOapttgyS1uUgah35V3I+FBEVDQQIgD1OT\
        THGpDaBKa626BFnosSz438IPVzBugPch82KejbkwXAYDVR0RBFUwU4IkZm9nLmFscGhhLmRldmVsb3Bt\
        ZW50Lm1vYmlsZWNvaW4uY29tgitmb2ctcmVwb3J0LmFscGhhLmRldmVsb3BtZW50Lm1vYmlsZWNvaW4u\
        Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQBWrrkeZVFU91QJJEtGLKlWp+ScWsOWfDC8VZPrODaaPdmsXhVH\
        /0HCfNPpJnX8/0Hc4tXLfSWR8VtkoI06l8dgpKBByAxQJTkOVkf8UjzKt5xOaiQauqjk6hsjFm2lFw+p\
        fmpBWF8fviIX0R4Nu0hdcV/hhX/jln5dWRz9NKSBue26CoHUaIllazclM/m3qms4ulrn5Ph6FjOIqPAa\
        rJIp/YvoLXmTQoWEND20mdH5TddizRtnwFRijOGTalNtDtMqrAek3H6sAb3617ngswoC/4ypyO8Chc1y\
        RpMPpTX8aGWUq8ApLE8OX9ps2IqXMsrLOWDs0u3HEfxD73EiHKEv1ryzrNUgy5QFTt+fvt9Zgr9+A4SV\
        Nzt25Mul5xT6VeVhNDMmUel5UzZjc0CvMvss0QC7s0EhGHNRkImvWsGQhbmgaEQpNoBR0KPynAzugdu+\
        oG2XgZQ3cZ2WpJygjBlEHfLzRakiRXxjPIFtoKcwAjGNxONIfzxyCbXtHRoVcbvxlQEPtYtLi45CM7XH\
        lljCs2Gt/T/R1rYwWsWTayyWBlu5VB7KQDkWO+44HpOe+BcjNtBB0Pya/8agCj0POAaU2UusMcLu4K+q\
        25mzCFt8KcS9CJDS17kow3KXtdNumv0CoB7zCT4LBuprEVDqiLgCgH6jMo2xkGHbqshOs84SSg==
        """,
        """
        MIIG1TCCBL2gAwIBAgIQbFWr29AHksedBwzYEZ7WvzANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMC\
        VVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg\
        VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRo\
        b3JpdHkwHhcNMjAwMTMwMDAwMDAwWhcNMzAwMTI5MjM1OTU5WjBLMQswCQYDVQQGEwJBVDEQMA4GA1UE\
        ChMHWmVyb1NTTDEqMCgGA1UEAxMhWmVyb1NTTCBSU0EgRG9tYWluIFNlY3VyZSBTaXRlIENBMIICIjAN\
        BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAhmlzfqO1Mdgj4W3dpBPTVBX1AuvcAyG1fl0dUnw/Meue\
        CWzRWTheZ35LVo91kLI3DDVaZKW+TBAsJBjEbYmMwcWSTWYCg5334SF0+ctDAsFxsX+rTDh9kSrG/4mp\
        6OShubLaEIUJiZo4t873TuSd0Wj5DWt3DtpAG8T35l/v+xrN8ub8PSSoX5Vkgw+jWf4KQtNvUFLDq8mF\
        WhUnPL6jHAADXpvs4lTNYwOtx9yQtbpxwSt7QJY1+ICrmRJB6BuKRt/jfDJF9JscRQVlHIxQdKAJl7oa\
        VnXgDkqtk2qddd3kCDXd74gv813G91z7CjsGyJ93oJIlNS3UgFbD6V54JMgZ3rSmotYbz98oZxX7MKbt\
        Cm1aJ/q+hTv2YK1yMxrnfcieKmOYBbFDhnW5O6RMA703dBK92j6XRN2EttLkQuujZgy+jXRKtaWMIlkN\
        kWJmOiHmErQngHvtiNkIcjJumq1ddFX4iaTI40a6zgvIBtxFeDs2RfcaH73er7ctNUUqgQT5rFgJhMmF\
        x76rQgB5OZUkodb5k2ex7P+Gu4J86bS15094UuYcV09hVeknmTh5Ex9CBKipLS2W2wKBakf+aVYnNCU6\
        S0nASqt2xrZpGC1v7v6DhuepyyJtn3qSV2PoBiU5Sql+aARpwUibQMGm44gjyNDqDlVp+ShLQlUH9x8C\
        AwEAAaOCAXUwggFxMB8GA1UdIwQYMBaAFFN5v1qqK0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQWBBTI2Xho\
        otkZaNU9ct5fCj7ctYaGpjAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHSUE\
        FjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwIgYDVR0gBBswGTANBgsrBgEEAbIxAQICTjAIBgZngQwBAgEw\
        UAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRp\
        ZmljYXRpb25BdXRob3JpdHkuY3JsMHYGCCsGAQUFBwEBBGowaDA/BggrBgEFBQcwAoYzaHR0cDovL2Ny\
        dC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUFkZFRydXN0Q0EuY3J0MCUGCCsGAQUFBzABhhlodHRw\
        Oi8vb2NzcC51c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAVDwoIzQDVercT0eYqZjBNJ8VN\
        WwVFlQOtZERqn5iWnEVaLZZdzxlbvz2Fx0ExUNuUEgYkIVM4YocKkCQ7hO5noicoq/DrEYH5IuNcuW1I\
        8JJZ9DLuB1fYvIHlZ2JG46iNbVKA3ygAEz86RvDQlt2C494qqPVItRjrz9YlJEGT0DrttyApq0YLFDzf\
        +Z1pkMhh7c+7fXeJqmIhfJpduKc8HEQkYQQShen426S3H0JrIAbKcBCiyYFuOhfyvuwVCFDfFvrjADjd\
        4jX1uQXd161IyFRbm89s2Oj5oU1wDYz5sx+hoCuh6lSs+/uPuWomIq3y1GDFNafW+LsHBU16lQo5Q2yh\
        25laQsKRgyPmMpHJ98edm6y2sHUabASmRHxvGiuwwE25aDU02SAeepyImJ2CzB80YG7WxlynHqNhpE7x\
        fC7PzQlLgmfEHdU+tHFeQazRQnrFkW2WkqRGIq7cKRnyypvjPMkjeiV9lRdAM9fSJvsB3svUuu1coIG1\
        xxI1yegoGM4r5QP4RGIVvYaiI76C0djoSbQ/dkIUUXQuB8AL5jyH34g3BZaaXyvpmnV4ilppMXVAnAYG\
        ON51WhJ6W0xNdNJwzYASZYH+tmCWI+N60Gv2NNMGHwMZ7e9bXgzUCZH5FaBFDGR5S9VWqHB73Q+OyIVv\
        IbKYcSc2w/aSuFKGSA==
        """,
        """
        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
        """,
        ]
    }

    static var intermediateCertificateBase64: String {
        """
        MIIG1TCCBL2gAwIBAgIQbFWr29AHksedBwzYEZ7WvzANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMC\
        VVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUg\
        VVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRo\
        b3JpdHkwHhcNMjAwMTMwMDAwMDAwWhcNMzAwMTI5MjM1OTU5WjBLMQswCQYDVQQGEwJBVDEQMA4GA1UE\
        ChMHWmVyb1NTTDEqMCgGA1UEAxMhWmVyb1NTTCBSU0EgRG9tYWluIFNlY3VyZSBTaXRlIENBMIICIjAN\
        BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAhmlzfqO1Mdgj4W3dpBPTVBX1AuvcAyG1fl0dUnw/Meue\
        CWzRWTheZ35LVo91kLI3DDVaZKW+TBAsJBjEbYmMwcWSTWYCg5334SF0+ctDAsFxsX+rTDh9kSrG/4mp\
        6OShubLaEIUJiZo4t873TuSd0Wj5DWt3DtpAG8T35l/v+xrN8ub8PSSoX5Vkgw+jWf4KQtNvUFLDq8mF\
        WhUnPL6jHAADXpvs4lTNYwOtx9yQtbpxwSt7QJY1+ICrmRJB6BuKRt/jfDJF9JscRQVlHIxQdKAJl7oa\
        VnXgDkqtk2qddd3kCDXd74gv813G91z7CjsGyJ93oJIlNS3UgFbD6V54JMgZ3rSmotYbz98oZxX7MKbt\
        Cm1aJ/q+hTv2YK1yMxrnfcieKmOYBbFDhnW5O6RMA703dBK92j6XRN2EttLkQuujZgy+jXRKtaWMIlkN\
        kWJmOiHmErQngHvtiNkIcjJumq1ddFX4iaTI40a6zgvIBtxFeDs2RfcaH73er7ctNUUqgQT5rFgJhMmF\
        x76rQgB5OZUkodb5k2ex7P+Gu4J86bS15094UuYcV09hVeknmTh5Ex9CBKipLS2W2wKBakf+aVYnNCU6\
        S0nASqt2xrZpGC1v7v6DhuepyyJtn3qSV2PoBiU5Sql+aARpwUibQMGm44gjyNDqDlVp+ShLQlUH9x8C\
        AwEAAaOCAXUwggFxMB8GA1UdIwQYMBaAFFN5v1qqK0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQWBBTI2Xho\
        otkZaNU9ct5fCj7ctYaGpjAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHSUE\
        FjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwIgYDVR0gBBswGTANBgsrBgEEAbIxAQICTjAIBgZngQwBAgEw\
        UAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRp\
        ZmljYXRpb25BdXRob3JpdHkuY3JsMHYGCCsGAQUFBwEBBGowaDA/BggrBgEFBQcwAoYzaHR0cDovL2Ny\
        dC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUFkZFRydXN0Q0EuY3J0MCUGCCsGAQUFBzABhhlodHRw\
        Oi8vb2NzcC51c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAVDwoIzQDVercT0eYqZjBNJ8VN\
        WwVFlQOtZERqn5iWnEVaLZZdzxlbvz2Fx0ExUNuUEgYkIVM4YocKkCQ7hO5noicoq/DrEYH5IuNcuW1I\
        8JJZ9DLuB1fYvIHlZ2JG46iNbVKA3ygAEz86RvDQlt2C494qqPVItRjrz9YlJEGT0DrttyApq0YLFDzf\
        +Z1pkMhh7c+7fXeJqmIhfJpduKc8HEQkYQQShen426S3H0JrIAbKcBCiyYFuOhfyvuwVCFDfFvrjADjd\
        4jX1uQXd161IyFRbm89s2Oj5oU1wDYz5sx+hoCuh6lSs+/uPuWomIq3y1GDFNafW+LsHBU16lQo5Q2yh\
        25laQsKRgyPmMpHJ98edm6y2sHUabASmRHxvGiuwwE25aDU02SAeepyImJ2CzB80YG7WxlynHqNhpE7x\
        fC7PzQlLgmfEHdU+tHFeQazRQnrFkW2WkqRGIq7cKRnyypvjPMkjeiV9lRdAM9fSJvsB3svUuu1coIG1\
        xxI1yegoGM4r5QP4RGIVvYaiI76C0djoSbQ/dkIUUXQuB8AL5jyH34g3BZaaXyvpmnV4ilppMXVAnAYG\
        ON51WhJ6W0xNdNJwzYASZYH+tmCWI+N60Gv2NNMGHwMZ7e9bXgzUCZH5FaBFDGR5S9VWqHB73Q+OyIVv\
        IbKYcSc2w/aSuFKGSA==
        """
    }

    /// Baltimore CyberTrust Root: https://www.digicert.com/digicert-root-certificates.htm
    static var wrongIntermediateCertificateBase64: String {
        """
        MIIDdzCCAl+gAwIBAgIEAgAAuTANBgkqhkiG9w0BAQUFADBaMQswCQYDVQQGEwJJRTESMBAGA1UEChMJQmFsdGltb3J\
        lMRMwEQYDVQQLEwpDeWJlclRydXN0MSIwIAYDVQQDExlCYWx0aW1vcmUgQ3liZXJUcnVzdCBSb290MB4XDTAwMDUxMj\
        E4NDYwMFoXDTI1MDUxMjIzNTkwMFowWjELMAkGA1UEBhMCSUUxEjAQBgNVBAoTCUJhbHRpbW9yZTETMBEGA1UECxMKQ\
        3liZXJUcnVzdDEiMCAGA1UEAxMZQmFsdGltb3JlIEN5YmVyVHJ1c3QgUm9vdDCCASIwDQYJKoZIhvcNAQEBBQADggEP\
        ADCCAQoCggEBAKMEuyKrmD1X6CZymrV51Cni4eiVgLGw41uOKymaZN+hXe2wCQVt2yguzmKiYv60iNoS6zjrIZ3AQSs\
        BUnuId9Mcj8e6uYi1agnnc+gRQKfRzMpijS3ljwumUNKoUMMo6vWrJYeKmpYcqWe4PwzV9/lSEy/CG9VwcPCPwBLKBs\
        ua4dnKM3p31vjsufFoREJIE9LAwqSuXmD+tqYF/LTdB1kC1FkYmGP1pWPgkAx9XbIGevOF6uvUA65ehD5f/xXtabz5O\
        TZydc93Uk3zyZAsuT3lySNTPx8kmCFcB5kpvcY67Oduhjprl3RjM71oGDHweI12v/yejl0qhqdNkNwnGjkCAwEAAaNF\
        MEMwHQYDVR0OBBYEFOWdWTCCR1jMrPoIVDaGezq1BE3wMBIGA1UdEwEB/wQIMAYBAf8CAQMwDgYDVR0PAQH/BAQDAgE\
        GMA0GCSqGSIb3DQEBBQUAA4IBAQCFDF2O5G9RaEIFoN27TyclhAO992T9Ldcw46QQF+vaKSm2eT929hkTI7gQCvlYpN\
        RhcL0EYWoSihfVCr3FvDB81ukMJY2GQE/szKN+OMY3EU/t3WgxjkzSswF07r51XgdIGn9w/xZchMB5hbgF/X++ZRGjD\
        8ACtPhSNzkE1akxehi/oCr0Epn3o0WC4zxe9Z2etciefC7IpJ5OCBRLbf1wbWsaY71k5h+3zvDyny67G7fyUIhzksLi\
        4xaNmjICq44Y3ekQEe5+NauQrz4wlHrQMz2nZQ/1/I6eYs9HRCwBXbsdtTLSR9I4LtD+gdwyah617jzV/OeBHRnDJEL\
        qYzmp
        """
    }
}
