//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//

@testable import TestSetupClient
import XCTest

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

    static let shared = try? Self.load()

    static func load() throws -> Self {
        guard
            let processInfoFileUrl = Bundle.module.url(
                forResource: "process_info",
                withExtension: "json"
            ),
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
