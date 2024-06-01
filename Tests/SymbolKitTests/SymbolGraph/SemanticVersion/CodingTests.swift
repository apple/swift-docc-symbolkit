/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import XCTest
@testable import SymbolKit

final class CodingTests:XCTestCase {
    func testEncodingToJSON() throws {
        func assertEncoding(_ version: SymbolGraph.SemanticVersion, to expectedJSONObject: String) throws {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = [.withoutEscapingSlashes, .sortedKeys]
            let encodedVersion = try jsonEncoder.encode(version)
            XCTAssertEqual(
                String(data: encodedVersion, encoding: .utf8),
                // Because Semantic Versioning 2.0.0 does not allow whitespace in identifiers, we can remove whitespace from the expected JSON object string.
                expectedJSONObject.filter { !$0.isWhitespace }
            )
        }
        
        let testCases: [(version: SymbolGraph.SemanticVersion, expectedJSONObject: String)] = [
            (try .init(major: 0, minor: 0, patch: 0), #"{"major":0,"minor":0,"patch":0}"#),
            (try .init(major: 6, minor: 9, patch: 42), #"{"major":6,"minor":9,"patch":42}"#),
            (try .init(major: 1, minor: 2, patch: 3, prerelease: "beta-004.5"), #"{"major":1,"minor":2,"patch":3,"prerelease":"beta-004.5"}"#),
            (try .init(major: 6, minor: 7, patch: 8, buildMetadata: "2020-02-02.sha256-C951120B9D2E83CCCF8F51477FF53943447D56899185E0E0DC7C3EDFBA19CD60"), #"{"buildMetadata":"2020-02-02.sha256-C951120B9D2E83CCCF8F51477FF53943447D56899185E0E0DC7C3EDFBA19CD60","major":6,"minor":7,"patch":8}"#),
            (try .init(major: 9, minor: 10, patch: 11, prerelease: "alpha42.release-candidate-1", buildMetadata: "md5-8981EDE66EBF3F83819F709A73B22BBA"), #"{"buildMetadata":"md5-8981EDE66EBF3F83819F709A73B22BBA","major":9,"minor":10,"patch":11,"prerelease":"alpha42.release-candidate-1"}"#)
        ]
        
        try testCases.forEach { try assertEncoding($0.version, to: $0.expectedJSONObject) }
    }
    
    func testDecodingFromJSON() throws {
        func assertDecoding(_ jsonObject: String, to expectedVersion: SymbolGraph.SemanticVersion) throws {
            let jsonDecoder = JSONDecoder()
            let jsonObjectData = Data(jsonObject.utf8)
            let decodedVersion = try jsonDecoder.decode(SymbolGraph.SemanticVersion.self, from: jsonObjectData)
            XCTAssertEqual(decodedVersion, expectedVersion)
        }
        
        let validCases: [(jsonObject: String, expectedVersion: SymbolGraph.SemanticVersion)] = [
            (#"{"major":0,"minor":0,"patch":0}"#, try .init(major: 0, minor: 0, patch: 0)),
            (#"{"major":6,"minor":7,"patch":42}"#, try .init(major: 6, minor: 7, patch: 42)),
            (#"{"major":1,"minor":2,"patch":3,"prerelease":"-41ph4-1337.7.0"}"#, try .init(major: 1, minor: 2, patch: 3, prerelease: "-41ph4-1337.7.0")),
            (#"{"major":8,"minor":9,"patch":10,"buildMetadata":"LTS.sha256-076F19B8ECCD0B911C407C4881DE9D0C1D8128B631CF52DBB7BB96C11EA5D5EA"}"#, try .init(major: 8, minor: 9, patch: 10, buildMetadata: "LTS.sha256-076F19B8ECCD0B911C407C4881DE9D0C1D8128B631CF52DBB7BB96C11EA5D5EA")),
            (#"{"major":11,"minor":12,"patch":13,"prerelease":"beta.golden-master.42","buildMetadata":"md5-5FDD8FAC22BF07D9010F7F482745F6D5"}"#, try .init(major: 11, minor: 12, patch: 13, prerelease: "beta.golden-master.42", buildMetadata: "md5-5FDD8FAC22BF07D9010F7F482745F6D5"))
        ]
        
        func assertSemanticVersionErrorThrownFromDecoding(_ jsonObject: String) {
            let jsonDecoder = JSONDecoder()
            let jsonObjectData = Data(jsonObject.utf8)
            XCTAssertThrowsError(try jsonDecoder.decode(SymbolGraph.SemanticVersion.self, from: jsonObjectData)) { error in
                XCTAssertTrue(error is SymbolGraph.SemanticVersionError)
            }
        }
        
        try validCases.forEach { try assertDecoding($0.jsonObject, to: $0.expectedVersion) }
        
        let invalidCases = [
            #"{"major":4,"minor":5,"patch":6,"prerelease":""}"#,
            #"{"major":7,"minor":8,"patch":9,"prerelease":" "}"#,
            #"{"major":0,"minor":1,"patch":2,"prerelease":"."}"#,
            #"{"major":3,"minor":4,"patch":5,"prerelease":".."}"#,
            #"{"major":6,"minor":7,"patch":8,"prerelease":".a"}"#,
            #"{"major":9,"minor":0,"patch":1,"prerelease":"b."}"#,
            #"{"major":2,"minor":3,"patch":4,"prerelease":"00"}"#,
            #"{"major":5,"minor":6,"patch":7,"prerelease":"01"}"#,
            #"{"major":8,"minor":9,"patch":0,"prerelease":" 0"}"#,
            #"{"major":9,"minor":8,"patch":7,"prerelease":"@#"}"#,
            #"{"major":6,"minor":5,"patch":4,"prerelease":"œ∑"}"#,
            #"{"major":3,"minor":2,"patch":1,"prerelease":"+"}"#,
            
            #"{"major":0,"minor":9,"patch":8,"buildMetadata":""}"#,
            #"{"major":7,"minor":6,"patch":5,"buildMetadata":" "}"#,
            #"{"major":4,"minor":3,"patch":2,"buildMetadata":"+"}"#,
            #"{"major":1,"minor":0,"patch":9,"buildMetadata":"."}"#,
            #"{"major":8,"minor":7,"patch":6,"buildMetadata":".."}"#,
            #"{"major":5,"minor":4,"patch":3,"buildMetadata":".a"}"#,
            #"{"major":2,"minor":1,"patch":0,"buildMetadata":"b."}"#,
            #"{"major":0,"minor":1,"patch":1,"buildMetadata":" 0"}"#,
            #"{"major":2,"minor":3,"patch":5,"buildMetadata":"@#"}"#,
            #"{"major":8,"minor":1,"patch":3,"buildMetadata":"¥ø"}"#,
            
            #"{"major":2,"minor":1,"patch":3,"prerelease":"","buildMetadata":""}"#,
        ]
        
        invalidCases.forEach { assertSemanticVersionErrorThrownFromDecoding($0) }
    }
}
