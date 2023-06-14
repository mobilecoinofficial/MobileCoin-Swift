//
//  File.swift
//  
//
//  Created by Adam Mork on 6/13/23.
//

import Foundation

struct TestSecrets: Codable {
    let DEV_NETWORK_AUTH_USERNAME: String
    let DEV_NETWORK_AUTH_PASSWORD: String
    let TESTNET_TEST_ACCOUNT_MNEMONICS_COMMA_SEPERATED: String
    let MOBILEDEV_TEST_ACCOUNT_MNEMONICS_COMMA_SEPERATED: String
    let DYNAMIC_TEST_ACCOUNT_SEED_ENTROPIES_COMMA_SEPARATED: String
    let DYNAMIC_FOG_AUTHORITY_SPKI: String
    
    static var shared: TestSecrets = {
        (try! load())
    }()
    
    static func load() throws -> Self {
        // We're using SPM
        var secretsFileUrl: URL?
        #if canImport(LibMobileCoinHTTP)
        secretsFileUrl = Bundle.module.url(
            forResource: "secrets",
            withExtension: "json"
        )
        #else
        // We're using cocoapods
        secretsFileUrl = try Bundle.url("secrets", "json")
        #endif
        
        guard
            let secretsFileUrl = secretsFileUrl,
            let secretsFileData = try? Data(contentsOf: secretsFileUrl)
        else {
            fatalError(
                "No `secrets.json` file found." +
                "initialize with `make init-secrets`" +
                "Or, make duplicate `secrets.json.sample` and remove the `.sample` extension."
            )
        }
        
        return try JSONDecoder().decode(Self.self, from: secretsFileData)
    }
}

