//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//

import Foundation
import MobileCoin

struct NetworkPresets {

    static let fogAuthoritySpkiB64Encoded = """
    MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvnB9wTbTOT5uoizRYaYbw7XIEkInl8E7MGOA\
    Qj+xnC+F1rIXiCnc/t1+5IIWjbRGhWzo7RAwI5sRajn2sT4rRn9NXbOzZMvIqE4hmhmEzy1YQNDnfALA\
    WNQ+WBbYGW+Vqm3IlQvAFFjVN1YYIdYhbLjAPdkgeVsWfcLDforHn6rR3QBZYZIlSBQSKRMY/tywTxeT\
    CvK2zWcS0kbbFPtBcVth7VFFVPAZXhPi9yy1AvnldO6n7KLiupVmojlEMtv4FQkk604nal+j/dOplTAT\
    V8a9AJBbPRBZ/yQg57EG2Y2MRiHOQifJx0S5VbNyMm9bkS8TD7Goi59aCW6OT1gyeotWwLg60JRZTfyJ\
    7lYWBSOzh0OnaCytRpSWtNZ6barPUeOnftbnJtE8rFhF7M4F66et0LI/cuvXYecwVwykovEVBKRF4HOK\
    9GgSm17mQMtzrD7c558TbaucOWabYR04uhdAc3s10MkuONWG0wIQhgIChYVAGnFLvSpp2/aQEq3xrRSE\
    TxsixUIjsZyWWROkuA0IFnc8d7AmcnUBvRW7FT/5thWyk5agdYUGZ+7C1o69ihR1YxmoGh69fLMPIEOh\
    Yh572+3ckgl2SaV4uo9Gvkz8MMGRBcMIMlRirSwhCfozV2RyT5Wn1NgPpyc8zJL7QdOhL7Qxb+5WjnCV\
    rQYHI2cCAwEAAQ==
    """
    
    static let fogUrl = "fog://fog.test.mobilecoin.com"

    private static let allowedHardeiningAdvisories = [
        "INTEL-SA-00334",
        "INTEL-SA-00615",
        "INTEL-SA-00657",
    ]
    
    // v1.1.0 Enclave Values
    static let legacy_v1_1_0_testNetConsensusMrEnclaveHex =
    "9659ea738275b3999bf1700398b60281be03af5cb399738a89b49ea2496595af"
    static let legacy_v1_1_0_testNetFogViewMrEnclaveHex =
    "e154f108c7758b5aa7161c3824c176f0c20f63012463bf3cc5651e678f02fb9e"
    static let legacy_v1_1_0_testNetFogLedgerMrEnclaveHex =
    "768f7bea6171fb83d775ee8485e4b5fcebf5f664ca7e8b9ceef9c7c21e9d9bf3"
    static let legacy_v1_1_0_testNetFogReportMrEnclaveHex =
    "a4764346f91979b4906d4ce26102228efe3aba39216dec1e7d22e6b06f919f11"
    
    // v2.0.0 Enclave Values
    static let legacy_v2_0_0_testNetConsensusMrEnclaveHex =
    "01746f4dd25f8623d603534425ed45833687eca2b3ba25bdd87180b9471dac28"
    static let legacy_v2_0_0_testNetFogViewMrEnclaveHex =
    "3d6e528ee0574ae3299915ea608b71ddd17cbe855d4f5e1c46df9b0d22b04cdb"
    static let legacy_v2_0_0_testNetFogLedgerMrEnclaveHex =
    "92fb35d0f603ceb5eaf2988b24a41d4a4a83f8fb9cd72e67c3bc37960d864ad6"
    static let legacy_v2_0_0_testNetFogReportMrEnclaveHex =
    "3e9bf61f3191add7b054f0e591b62f832854606f6594fd63faef1e2aedec4021"
    
    // v3.0.0 Enclave Values
    static let legacy_v3_0_0_testNetConsensusMrEnclaveHex =
    "5fe2b72fe5f01c269de0a3678728e7e97d823a953b053e43fbf934f439d290e6"
    static let legacy_v3_0_0_testNetFogViewMrEnclaveHex =
    "be1d711887530929fbc06ef8b77b618db15e9cd1dd0265559ea45f60a532ee52"
    static let legacy_v3_0_0_testNetFogLedgerMrEnclaveHex =
    "d5159ba907066384fae65842b5311f853b028c5ee4594f3b38dfc02acddf6fe3"
    static let legacy_v3_0_0_testNetFogReportMrEnclaveHex =
    "d901b5c4960f49871a848fd157c7c0b03351253d65bb839698ddd5df138ad7b6"
    
    // v4.0.0 Enclave Values
    static let testNetConsensusMrEnclaveHex =
    "4f3879bfffb7b9f86a33086202b6120a32da0ca159615fbbd6fbac6aa37bbf02"
    static let testNetFogViewMrEnclaveHex =
    "f52b3dc018195eae42f543e64e976c818c06672b5489746e2bf74438d488181b"
    static let testNetFogLedgerMrEnclaveHex =
    "23ececb2482e3b1d9e284502e2beb65ae76492f2791f3bfef50852ee64b883c3"
    static let testNetFogReportMrEnclaveHex =
    "16d73984c2d2712156135ab69987ca78aca67a2cf4f0f2287ea584556f9d223a"

    static func defaultAttestation(_ mrEnclaveHexs: [String]) -> Attestation {
        var mrEnclaves = [Attestation.MrEnclave]()
        mrEnclaveHexs.forEach { mrEnclaveHex in
            if let data = Data(base64Encoded: mrEnclaveHex) {
                if let mrEnclave = try? Attestation.MrEnclave.make(
                    mrEnclave: data,
                    allowedHardeningAdvisories: NetworkPresets.allowedHardeiningAdvisories).get() {
                    mrEnclaves.append(mrEnclave)
                }
            }
        }
        return Attestation(mrEnclaves: mrEnclaves)
    }
    
    static func consensusAttestation() -> Attestation {
        defaultAttestation([
            NetworkPresets.testNetConsensusMrEnclaveHex,
            NetworkPresets.legacy_v2_0_0_testNetConsensusMrEnclaveHex,
            NetworkPresets.legacy_v1_1_0_testNetConsensusMrEnclaveHex,
        ])
    }

    static func fogViewAttestation() -> Attestation {
        defaultAttestation([
            NetworkPresets.testNetFogViewMrEnclaveHex,
            NetworkPresets.legacy_v1_1_0_testNetFogViewMrEnclaveHex,
        ])
    }

    static func fogReportAttestation() -> Attestation {
        defaultAttestation([
            NetworkPresets.testNetFogReportMrEnclaveHex,
            NetworkPresets.legacy_v1_1_0_testNetFogReportMrEnclaveHex,
        ])
    }

    static func fogLedgerAttestation() -> Attestation {
        defaultAttestation([
            NetworkPresets.testNetFogLedgerMrEnclaveHex,
            NetworkPresets.legacy_v1_1_0_testNetFogLedgerMrEnclaveHex,
        ])
    }
}
