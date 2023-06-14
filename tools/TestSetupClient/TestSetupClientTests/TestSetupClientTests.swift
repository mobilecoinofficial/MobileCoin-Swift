//
//  TestSetupClientTests.swift
//  TestSetupClientTests
//
//  Created by Cary Bakker on 4/18/23.
//

import XCTest
@testable import TestSetupClient

@available(iOS 15.0, macOS 12.0, *)
final class TestSetupClientTests: XCTestCase {

    func testCreateAccounts() async throws {
        guard let testAccountSeed = ProcessInfo.processInfo.combined("testAccountSeed")
        else {
            XCTFail("Unable to get testAccountSeed value")
            return
        }

        guard let srcAcctEntropyString = ProcessInfo.processInfo.combined("srcAcctEntropyString")
        else {
            XCTFail("Unable to get source account entropy string")
            return
        }

        let result = await TestWalletCreator().createAccounts(
            srcAcctEntropyString: srcAcctEntropyString,
            testAccountSeed: testAccountSeed)
        
        switch result {
        case .success:
            print("Test accounts created successfully")
        case let .failure(error):
            switch error {
            case .error(let message):
                XCTFail("Test account creation failed with error: \(message)")
            }
        }
    }

}

extension ProcessInfo {
    func combined(_ variable: String) -> String? {
        // Check environment first, then check "local environment" (secrets JSON file)
        guard let value = ProcessInfo.processInfo.environment[variable] else {
            switch variable {
            case "testAccountSeed":
                return ProcessInfoLocal.shared?.testAccountSeed
            case "srcAcctEntropyString":
                return ProcessInfoLocal.shared?.srcAcctEntropyString
            default:
                return nil
            }
        }
        
        return value
    }
}

struct ProcessInfoLocal: Decodable {
    let testAccountSeed: String
    let srcAcctEntropyString: String

    static var shared = try? Self.load()

    static func load() throws -> Self {
        let processInfoFileUrl = Bundle.module.url(
            forResource: "process_info",
            withExtension: "json"
        )
        
        guard
            let processInfoFileUrl = processInfoFileUrl,
            let processInfoFileData = try? Data(contentsOf: processInfoFileUrl)
        else {
            fatalError(
                "No `process_info.json` file found." +
                "initialize with `make init-secrets`" +
                "Or, make duplicate `process_info.json.sample` and remove the `.sample` extension."
            )
        }
        
        return try JSONDecoder().decode(Self.self, from: processInfoFileData)
    }
}

struct TestingError: Error {
    let reason: String

    init(_ reason: String) {
        self.reason = reason
    }
}

extension TestingError: CustomStringConvertible {
    var description: String {
        "Testing error: \(reason)"
    }
}

extension Bundle {
    public static let setupclient_BundleIdentifier = Bundle.module.bundleIdentifier!
    
    public static func testSetupClientModuleUrl(_ resource: String, withExtension ext: String) throws -> URL {
        guard
            let url = Bundle.module.url(forResource: resource, withExtension: ext)
        else {
            throw TestingError("Failed to get url for resource: \(resource).\(ext)")
        }
        return url
    }
}
