//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

#if canImport(LibMobileCoinTestVector)
import LibMobileCoinTestVector
#endif

protocol TestVector {}

extension TestVector where Self: Decodable {

    static func testcases() throws -> [Self] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dataDecodingStrategy = .deferredToData

        
        let filename = String(describing: Self.self).camelCaseToSnakeCase()
        #if canImport(LibMobileCoinTestVector)
        let path = try Bundle.testVectorModuleUrl(filename)
        #else
        let path = try Bundle.url(filename, "jsonl")
        #endif
        let text = try String(contentsOf: path, encoding: .utf8)
        let lines = text.components(separatedBy: CharacterSet.newlines).filter { !$0.isEmpty }
        return try lines.map { try decoder.decode(Self.self, from: $0.data(using: .utf8)!) }
    }

}
