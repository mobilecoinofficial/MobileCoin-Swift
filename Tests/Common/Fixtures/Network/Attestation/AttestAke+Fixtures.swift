//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

@testable import MobileCoin
import XCTest

extension AttestAke {
    enum Fixtures {}
}

extension AttestAke.Fixtures {
    struct Default {
        let attestAke = AttestAke()

        let rng: @convention(c) (UnsafeMutableRawPointer?) -> UInt64 = testRngCallback
        let rngContext = TestRng()
        let authRequestData: Data
        let responderId = Self.responderId
        let attestationVerifier: AttestationVerifier

        init() throws {
            self.authRequestData = try XCTUnwrap(Data(base64Encoded: Self.authRequestDataBase64))
            self.attestationVerifier = try Self.attestationVerifier()
        }
    }
}

extension AttestAke.Fixtures {
    struct DefaultWithAuthBegin {
        let attestAke: AttestAke

        let authResponseData: Data
        let attestationVerifier: AttestationVerifier

        init() throws {
            self.authResponseData = try XCTUnwrap(
                Data(base64Encoded: Default.authResponseDataBase64))
            let defaultFixture = try Default()
            self.attestAke = defaultFixture.attestAke
            let authRequestData = attestAke.authBeginRequestData(
                responderId: defaultFixture.responderId,
                rng: defaultFixture.rng,
                rngContext: defaultFixture.rngContext)
            XCTAssertEqual(
                authRequestData.base64EncodedString(),
                Default.authRequestDataBase64)
            self.attestationVerifier = defaultFixture.attestationVerifier
        }
    }
}

extension AttestAke.Fixtures {
    struct DefaultAttested {
        let attestAkeCipher: AttestAke.Cipher

        init() throws {
            let authResponseData = try XCTUnwrap(
                Data(base64Encoded: Default.authResponseDataBase64))
            let attestAke = try DefaultWithAuthBegin().attestAke
            let verifier = try Default.attestationVerifier()
            self.attestAkeCipher = try attestAke.authEnd(
                authResponseData: authResponseData,
                attestationVerifier: verifier).get()
            XCTAssertTrue(attestAke.isAttested)
        }
    }
}

extension AttestAke.Fixtures {
    struct BlankFirstMessage {
        let attestAkeCipher: AttestAke.Cipher

        let aad = Data()
        let plaintext = Data()
        let encryptedData: Data

        init() throws {
            self.encryptedData = try XCTUnwrap(Data(base64Encoded: "ChTwWj7piGKspsOpw4KlQg=="))
            self.attestAkeCipher = try AttestAke.Fixtures.DefaultAttested().attestAkeCipher
        }
    }
}

extension AttestAke.Fixtures.Default {

    fileprivate static let responderId = "node1.mobiledev.mobilecoin.com:443"

    fileprivate static func attestation() throws -> Attestation {
        try Attestation.Fixtures.Default().consensusAttestation
    }

    fileprivate static func attestationVerifier() throws -> AttestationVerifier {
        AttestationVerifier(attestation: try attestation())
    }

    fileprivate static let authRequestDataBase64 =
        "RirBiNYMxQ+67j/DCQxwrFSnQ56n2SFsouqfDh7wciA="
    fileprivate static let authResponseDataBase64 = """
        oXtZxPg/INwprEGoXPAfknmrqqTDvNJnrWNt6tzzW3rwSnsJD53vYPk2w8SLrrBIUWxBeE6IUFYbJo+F0jDouCKwdOV\
        skTBjmaKU+VDc3YnsCuoKnfH9KPozjAjrpYQ0KbnOHbFq5mxvKszT8HAjOzs/cOFa90jXHS8oDnpeFG+F1EGJFxqkPw\
        Ux+2ft7hurQY7GKb1MoWNaiXm3t2Al5Mino5qw2SKLQH/I8FYhNjf63DSc8v/0lPBl86lH4bDr2M5p0DF2qcz62aF8Z\
        eC/SbZJWiPm+Z+i2C1pNJhbUfVTxuglOHIZYhLU1ukmJclZjxSCXJTgma2+l3vFiiL+0+IFgagyvYL9afyd/3odgisT\
        sJUFtspefZ8Mdy8RZYXE3j+wg80DemcVIKT35H4kijmMUFmfJH0xB/QV2baXH3FFD8HuEJnkt2KDnMkJ46sgddJkVQ/\
        DHbB8e92MNBllnJNkkN7flg626ejehYUR4BoAofLZtnuybGhigwb/zSWfhxKVGBMLCjKtsDey1TANvpUtt0kMDhxz+6\
        YPPQatgqgSqKlc++Qjfl+eA9Wng1gHG7HtsiYLe+88dZP6oeAKXrwH+kaQ6mEaJDoDMnUP2G6/r7yNUpEcbe42DjmJW\
        mZ9DJ42HAnMsY4c2NlqjhPrLngllgNjkKWKQemggCilPBMuav4XR4J/kRVn5mbpJ16s/lESDa1jPXcjU9UnjXfThY6M\
        F4YAqVJxFR4ztWzefuf+oV1HCKifmrNZiS4rFX7teQrAgEzRUZQQDdEoqO6k4V21YztLWQMNvyLBc+WMaedX9nO029E\
        WNIgiBS5df8LVujo6Kr4YzjHs5v5UAvHwrEp4MpSz5M22rSnqnQ+tzoE2E4q68Xefk4oJwplVxVGoV9XabkqYBa0opT\
        orS0ejzi68ojicPviY5xBWRQWhnbOMRgrNX9CdYTFF9esMnJzjwlF6xXWzXejx0AippvtYIZLyiWn5Gim/CCdhj84iY\
        uF0dgKr/YC0sTebFgjuKzcs6CKPnrY1MLdSzxlkcszkbUKb2Vzp131uzOSV4qKn5i3knOTPK9Qe8iGuRwsPvVew2CKJ\
        ksHq1ellSyuAk4FDVDa1iwcnNfkUGGclMXJ+AYmEj7XAvK90yjCwGc2AawFAJNv0O1/G6TgaFK+iWiMEjpARhfycMXr\
        TdItoc4O8OaXvZB93JT2DMtSXCXv29PpZldF112G2OW9aqIBXuIPuzsAvkrBnYqH0ecphwEzoqJU++WVWOrGjBrSD+K\
        rp3X5LGIPG5JT8+JEoAWOo3UpdeL7a6DqIkb7x+SLjyZDDmZUYJHomY+bAs2vsVxsXs/cJuucOJeI+bCfGOpCNvmoDo\
        Fe3iyIn+yPfEbe/+nvpX8mWiJjdpDue8rpZVpXVCI6sVZBuJuuLxASUlT3SgARnKphBVuzo1O8eWsN9M82kEM0Wd5PU\
        kzOKTp2IsBRmXWfnxugCHxtr+g6jKVwpc2aXtckDtvB5/nOk0/QV+zxny+wnK+oclrwmmkqmAZDexNBJR+Na0K/YbUt\
        vkesNkpGPYtSCTYNsoF75ynxv+0JDssscYgnpJvaqcQz3xrY4aehCDsJ8x+7A9IqE7ClI2dM/GK6OEy8i2esN70uxKP\
        +3GBMwXO57Q/R+3kBL/h8C+/LAh5RZHa9E73GfCHDZRyhCLI7UtRTL5JWshuHW/mhN/PYLbxIpvefUXifCPss3CcnoQ\
        SMm3dFpSqt2QPf623jQnFeF+JBDbPimagR2T95gpPliEzeGrMRiAme1p8hvHgrKmjZmzZGAiQwAhppX1C6KZBQeycGp\
        tdbpSkzmJ+obqM8VmMMY9ImOvnBm3CzWtRH/a+onkG4SXIUR5SDJEoUZE8TH8kaVacC1TMYyZsHFd623DnNOYAQx2F8\
        bvx5w4qrXewf7LxKgLgy2t3wcWKdtXfYKWfrCNArzA9TYgxlqhd6L5+EyzTNUbUriKljzT7XDPqHsAMRQs4uvWs0oaV\
        DbyARmtC4pKGar0DWtECtTn+K2yRRADRslM73NOqq6jDg4A1G2JBW2vIE/+UVvJuLqIWwEtssyBpZeUf14s35liE/qU\
        ol03agY1lVyOqsdGibbTBw8D9Ppr+IBFVx/nfvtxQmu4yEydulwYTPr/RLZ1YgauvDFr6ZHE0ZkVOL36DAUP393uSy/\
        6MbLJVskqlPouBLITIdJmAsYhf2UZYE/erE0z51N70gFajoDsmueGzcLRorTcNiRWcZDpci7iKNBtTByxoToufCsAgI\
        +Aha5xZUWyC5jcq9lwRQiLVwT4PsoPlZP1zgphrhC5t01Q/lev+3rkI4LzpQ6FSYvxAGmVSe7yZIObt4Z8N1NNRrH5z\
        FR1VGUXjOQsHLUs5Lc5bOmQn4yvfi8GECZ3fuHF7gHDarZWdgVL7cQrJQ5KCxmZbf16QcuGtq5b8tRILKJ8MmZnoICd\
        YaMD3MAQ/wTEgxrMKt4gIZwsUYEI2kKYXS94PqPQ6LEcgzIBYyzd125ynUb++hr2ZJnv+VXDD3QUHU1oQebflPDr5C1\
        wxOtHLP9U19mLHnJf8UWK2RxE+ztvAbe8YtYOR/kvP3km0HFJamRO3/D7dXNuKX7QLmD07veoVlbrRTRrWveHMKdjRi\
        UzG+YW1iI2tHbD61tKcYFjU+sr1AzzGBmOBUshSwXCjGBHww+mhoP2EzJhjDheVo/hy8RcLk3JFDtuQco04VeWaBJrP\
        oplMJ41eLM5FHb9yA1gAzBy/p/2CQUtSSBFEJ/NDdRZhK+oAwTPatJ5RmlDGNdfb2vYfM5GKNWJoQnkPIJUEkr2MnKa\
        QWGtqMfkH6sGRU3AbsMkkC6RZNucV8/+gm0LQW5+STxFR0KokslwLbiXzM4NAsSX2R/vpeHicvC5oxWhiihCz//kPtu\
        kE6iNOHKWH9kUmIaoYasfVbKK7i6GF4earmpXYuAfC5n0VDoXrR2DkQevuXF9YARKJYQogD/ejZOxklRwF/5kNegpOu\
        2NaCapYs+jpuPF9KYU+b88C5V+C5qkVwy+MYU/xK90twgzSWGRuV7bsTViL3BHvH7HBxFHVY93wx3xhzh23Nnh4dgKp\
        ZoAs92sAJaPsgdnhwFd0dBIUPFKb8e1i590TNd4yEiJW4aYQP/nZm1zWNwgUlnTC3js39yagfjJD8BdSwDKzuCgQeV/\
        xtjeSdMN0bRcfSbGAAh7GxHWbSDnBlkNZHFN00AgmSs8TUBCZyMmEEepTmyvboeT7x3gJJJbiatatl4uUtckzN7M+cc\
        9J5FDQCG6oIef14o+m5NsG/gv2LYKXzCmsHZRzIAJ9skNaLnvWrFVztUJlBML26uGBidbl7mHUg591/dQOlnYPNss3z\
        sPIat3lSrDArX26Idkz8ZLamP/PSFwbbzDXzN33JA7dJQf83s3oQ/lXj8B7lIgCtcdEXlFYvN61P2SImSJig+l7Vy1Z\
        6JU2dNK5pXtoHmNNMqxnK51E8Cok4h3QYY7fkYLu01gb53KnuO/NswR/1qa4amh3pJ5sTB9YjZIkpW8aw/0yrEiOCw4\
        CcIacJ/UwR+FQxg8fbif5IaYdBAhrc5ktb+fK8RP0wlCjJ98HMoQJqVbSjLHXnb0f2kP+wNF4KB0WNVZooEyNGU2K8q\
        Rs8B/NgzgWtowURDcmU35HHZR+dPmuj5nqc+apQInaNncVxNjJLbruKAyBnWxvCV2VpCtRvhT6CgBLNcwvLdRYlFJ53\
        cbEsw95oMqmJZViGsywTe86Nb7YtwjXQAhxMFFp9KuOeGDM4FCrl/GPTd9En1oQjzfUd+bFfLwvPR5MjGtvp9TT1vfD\
        6VNNLomCWdUhvCPE0FhFXCe7fRWdm2nYfNggTubJQpV8pXvOPkWFtm6497ycPzJpJqdrAWbwsFkSym7OAwn/oGfE4Cn\
        5qOipjO9rfXgMUO4tEeE/L4OZ4ZKQ9ZT4aqn5Hum2qrLhe4pTbYPiRF8mXErp2hma6/G/LLGipIFrGxvnTCTkeeb6j0\
        N6uNzeWbZk7sm/ypAnyZQWVnKaWm1HCptaPl4k9U5WNSP29iXwAX10N1wWkDxX6QDfXTVWVaSWeDL0qzrFi3ncTpxe6\
        N43qP/evDEF7YW0vaVlRPy3kBlvzpWH+DcocNY+GSFYMUPloT5tCnWIk0WH963pQEacOoC9VXgklVHHAhDdihIycwPO\
        7lVTyr2ZSdEJSSGWI+jvW3wEEKuE7o5fvB0PDpziB7ejnLFTnzwbjBbApMsBl8n16SdSTz7gFPxp+QPNo8vapfPrTNA\
        wWN8HCtGG35gdIswnPOuPbSn4m6IbDsPI2bQzTakPJEITW/F89o6YOmNV42p8dl4iwcswLpvHqBhSAOjF/EOae4Azf3\
        Gzj20VuSuLMdQvajO3xz0+7dgBkcz+OO8FfHFNij+dho/wtUbnLCbWHU6ueaC7HCQJw/hAu3wHNjlFOS97UL5om1GEl\
        seJ2qAE45ZbmB5XaFkEIWbPHO8rQwzqAhhQS3ziI+mCPNmlhrrk1ghUT6pO7lvY3pAtnWBKKtvbrEB2KJL3YKPUwDJP\
        jXHDNx4fdYR+v64CxlpFmd9ap2Zf9WH2juHPHlJ4zreW4ss6FIZf2bjXplm5wWjbRYW402Jgg/1xntopIrB9GaWmNu0\
        HxdWy9blSoVP7IAXx4WjwEyQ8JKjqInEapn9cKcc8+smGsiv5ugLZmndYQvZT3ed2q+q5FRcs1Z/LFnDG1IpVH+LLAI\
        wdv9+3pYfV52z3xXERzmJP7nXQdY0Kjft7Nhufoh/sb3+SCE+s8RlL91d5ha2YhCI2R6RjixnL4r2uAmXRM4KoP8b2T\
        jUNPXbiaZoqnRGI8/eTB5jRLnlJ8GcwDFO3SN3zn0lxd+ZCrdO+kU6/l0lV6rZIu3wCXXZ2eurVDt7PfdUYtgh3Vbfe\
        kuWWHjwZRCH00ivDFgXHeEJD4ICwP1RHWcpXx8hqSa0SJi3rxA6RtjDD0JyZRIDKKIqjrdhJDjqBwIql5qaS7qiW10t\
        0P6B5ybFYb/F+tYXHUSJKOMaOR6WB+pWsTW+0hx/7TltvI8Wy6c+QIBZzf5LXxzsh/ypAGhUUgxEbnq2GfZGuLUdxpI\
        0+LCJkrYNnLX5spOxYo3F5diNEC9WLl5Aj/1FiHxogXby6hLnrmF7Qi6cuE0c4oRz8HJS3D3GkakN+mOoeqmcANoBVk\
        zUh8XtLbbzSGTCu5it4jl0AAWMsT8lAWa3OKaikVCeEnw5re/068LKYpcMu3hmmr/lXS3qO4RZmKa9umd9dzxA0r1Nz\
        rmfJsARjcowRWBWOI0eLU/pyLzTg==
        """

}

extension AttestAke.Fixtures.BlankFirstMessage {

    static let bindingBase64 =
        "DIhSTcCCj2c84OIZg0Dsy3xdFdzBPassZ8wgmIUDjY9vqk1P9Ts+v9T5K8EsSnxHGUEi3+UQYXWfv7b0Tg3MDw=="

}
