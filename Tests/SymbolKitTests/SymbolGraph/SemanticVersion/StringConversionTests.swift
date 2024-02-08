/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import XCTest
@testable import SymbolKit

final class StringConversionTests: XCTestCase {
    func testCustomConversionToString() throws {
        
        //    MARK: .description
        
        XCTAssertEqual(try SymbolGraph.SemanticVersion(major: 0, minor: 0, patch: 0).description, "0.0.0")
        XCTAssertEqual(try SymbolGraph.SemanticVersion(major: 1, minor: 2, patch: 3).description, "1.2.3")
        
        XCTAssertEqual(try SymbolGraph.SemanticVersion(major: 2, minor: 3, patch: 4, prerelease: nil)       .description, "2.3.4")
        XCTAssertEqual(try SymbolGraph.SemanticVersion(major: 3, minor: 4, patch: 5, prerelease: "alpha-01").description, "3.4.5-alpha-01")
        XCTAssertEqual(try SymbolGraph.SemanticVersion(major: 4, minor: 5, patch: 6, prerelease: "beta.42") .description, "4.5.6-beta.42")
        
        XCTAssertEqual(try SymbolGraph.SemanticVersion(major: 5, minor: 6, patch: 7, buildMetadata: nil)         .description, "5.6.7")
        XCTAssertEqual(try SymbolGraph.SemanticVersion(major: 6, minor: 7, patch: 8, buildMetadata: "000")       .description, "6.7.8+000")
        XCTAssertEqual(try SymbolGraph.SemanticVersion(major: 7, minor: 8, patch: 9, buildMetadata: "2020-02-02").description, "7.8.9+2020-02-02")
        XCTAssertEqual(try SymbolGraph.SemanticVersion(major: 8, minor: 9, patch: 0, buildMetadata: "f0o.bar")   .description, "8.9.0+f0o.bar")
        
        XCTAssertEqual(
            try SymbolGraph.SemanticVersion(
                major: 9,
                minor: 8,
                patch: 7,
                prerelease: nil,
                buildMetadata: nil
            ).description,
            "9.8.7"
        )
        XCTAssertEqual(
            try SymbolGraph.SemanticVersion(
                major: 6,
                minor: 5,
                patch: 4,
                prerelease: "--.---",
                buildMetadata: nil
            ).description,
            "6.5.4---.---"
        )
        XCTAssertEqual(
            try SymbolGraph.SemanticVersion(
                major: 3,
                minor: 2,
                patch: 1,
                prerelease: nil,
                buildMetadata: "--.---"
            ).description,
            "3.2.1+--.---"
        )
        XCTAssertEqual(
            try SymbolGraph.SemanticVersion(
                major: 0,
                minor: 9,
                patch: 8,
                prerelease: "pre.release.42",
                buildMetadata: "build.metadata"
            ).description,
            "0.9.8-pre.release.42+build.metadata"
        )
        
        //    MARK: string interpolation
        
        XCTAssertEqual("\(try SymbolGraph.SemanticVersion(major: 0, minor: 0, patch: 0))", "0.0.0")
        XCTAssertEqual("\(try SymbolGraph.SemanticVersion(major: 1, minor: 2, patch: 3))", "1.2.3")
        
        XCTAssertEqual("\(try SymbolGraph.SemanticVersion(major: 2, minor: 3, patch: 4, prerelease: nil))"       , "2.3.4")
        XCTAssertEqual("\(try SymbolGraph.SemanticVersion(major: 3, minor: 4, patch: 5, prerelease: "alpha-01"))", "3.4.5-alpha-01")
        XCTAssertEqual("\(try SymbolGraph.SemanticVersion(major: 4, minor: 5, patch: 6, prerelease: "beta.42"))" , "4.5.6-beta.42")
        
        XCTAssertEqual("\(try SymbolGraph.SemanticVersion(major: 5, minor: 6, patch: 7, buildMetadata: nil))"         , "5.6.7")
        XCTAssertEqual("\(try SymbolGraph.SemanticVersion(major: 6, minor: 7, patch: 8, buildMetadata: "000"))"       , "6.7.8+000")
        XCTAssertEqual("\(try SymbolGraph.SemanticVersion(major: 7, minor: 8, patch: 9, buildMetadata: "2020-02-02"))", "7.8.9+2020-02-02")
        XCTAssertEqual("\(try SymbolGraph.SemanticVersion(major: 8, minor: 9, patch: 0, buildMetadata: "f0o.bar"))"   , "8.9.0+f0o.bar")
        
        XCTAssertEqual(
            "\(try SymbolGraph.SemanticVersion(major: 9, minor: 8, patch: 7, prerelease: nil, buildMetadata: nil))",
            "9.8.7"
        )
        XCTAssertEqual(
            "\(try SymbolGraph.SemanticVersion(major: 6, minor: 5, patch: 4, prerelease: "--.---", buildMetadata: nil))",
            "6.5.4---.---"
        )
        XCTAssertEqual(
            "\(try SymbolGraph.SemanticVersion(major: 3, minor: 2, patch: 1, prerelease: nil, buildMetadata: "--.---"))",
            "3.2.1+--.---"
        )
        XCTAssertEqual(
            "\(try SymbolGraph.SemanticVersion(major: 0, minor: 9, patch: 8, prerelease: "pre.release.42", buildMetadata: "build.metadata"))",
            "0.9.8-pre.release.42+build.metadata"
        )
    }
}
