/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import XCTest
@testable import SymbolKit

final class DirectInitializationTests: XCTestCase {
    func testInitializationFromAllComponents() throws {
        
        // MARK: primary public properties
        
        let version1 = try SymbolGraph.SemanticVersion(
            major: 0, minor: 0, patch: 0,
            prerelease: nil, buildMetadata: nil
        )
        XCTAssertEqual(version1.major, 0)
        XCTAssertEqual(version1.minor, 0)
        XCTAssertEqual(version1.patch, 0)
        XCTAssertEqual(version1.prereleaseIdentifiers, [])
        XCTAssertEqual(version1.buildMetadataIdentifiers, [])
        
        let version2 = try SymbolGraph.SemanticVersion(
            major: 1, minor: 2, patch: 3,
            prerelease: nil, buildMetadata: nil
        )
        XCTAssertEqual(version2.major, 1)
        XCTAssertEqual(version2.minor, 2)
        XCTAssertEqual(version2.patch, 3)
        XCTAssertEqual(version2.prereleaseIdentifiers, [])
        XCTAssertEqual(version2.buildMetadataIdentifiers, [])
        
        let version3 = try SymbolGraph.SemanticVersion(
            major: 42, minor: 41, patch: 40,
            prerelease: "beta.1337.0", buildMetadata: nil
        )
        XCTAssertEqual(version3.major, 42)
        XCTAssertEqual(version3.minor, 41)
        XCTAssertEqual(version3.patch, 40)
        XCTAssertEqual(version3.prereleaseIdentifiers, ["beta", "1337", "0"])
        XCTAssertEqual(version3.buildMetadataIdentifiers, [])
        
        let version4 = try SymbolGraph.SemanticVersion(
            major: 2, minor: 3, patch: 5,
            prerelease: nil, buildMetadata: "2022-05-23"
        )
        XCTAssertEqual(version4.major, 2)
        XCTAssertEqual(version4.minor, 3)
        XCTAssertEqual(version4.patch, 5)
        XCTAssertEqual(version4.prereleaseIdentifiers, [])
        XCTAssertEqual(version4.buildMetadataIdentifiers, ["2022-05-23"])
        
        let version5 = try SymbolGraph.SemanticVersion(
            major: 7, minor: 11, patch: 13,
            prerelease: "alpha-1.-42", buildMetadata: "010203.md5-d41d8cd98f00b204e9800998ecf8427e"
        )
        XCTAssertEqual(version5.major, 7)
        XCTAssertEqual(version5.minor, 11)
        XCTAssertEqual(version5.patch, 13)
        XCTAssertEqual(version5.prereleaseIdentifiers, ["alpha-1", "-42"])
        XCTAssertEqual(version5.buildMetadataIdentifiers, ["010203", "md5-d41d8cd98f00b204e9800998ecf8427e"])
        
        // MARK: default parameters
        
        let version6 = try SymbolGraph.SemanticVersion(major: 0, minor: 0, patch: 0)
        XCTAssertEqual(version6.major, version1.major)
        XCTAssertEqual(version6.minor, version1.minor)
        XCTAssertEqual(version6.patch, version1.patch)
        XCTAssertEqual(version6.prereleaseIdentifiers, version1.prereleaseIdentifiers)
        XCTAssertEqual(version6.buildMetadataIdentifiers, version1.buildMetadataIdentifiers)
        
        let version7 = try SymbolGraph.SemanticVersion(major: 1, minor: 2, patch: 3)
        XCTAssertEqual(version7.major, version2.major)
        XCTAssertEqual(version7.minor, version2.minor)
        XCTAssertEqual(version7.patch, version2.patch)
        XCTAssertEqual(version7.prereleaseIdentifiers, version2.prereleaseIdentifiers)
        XCTAssertEqual(version7.buildMetadataIdentifiers, version2.buildMetadataIdentifiers)
        
        let version8 = try SymbolGraph.SemanticVersion(major: 42, minor: 41, patch: 40, prerelease: "beta.1337.0")
        XCTAssertEqual(version8.major, version3.major)
        XCTAssertEqual(version8.minor, version3.minor)
        XCTAssertEqual(version8.patch, version3.patch)
        XCTAssertEqual(version8.prereleaseIdentifiers, version3.prereleaseIdentifiers)
        XCTAssertEqual(version8.buildMetadataIdentifiers, version3.buildMetadataIdentifiers)
        
        let version9 = try SymbolGraph.SemanticVersion(major: 2, minor: 3, patch: 5, buildMetadata: "2022-05-23")
        XCTAssertEqual(version9.major, version4.major)
        XCTAssertEqual(version9.minor, version4.minor)
        XCTAssertEqual(version9.patch, version4.patch)
        XCTAssertEqual(version9.prereleaseIdentifiers, version4.prereleaseIdentifiers)
        XCTAssertEqual(version9.buildMetadataIdentifiers, version4.buildMetadataIdentifiers)
        
        // MARK: invalid components
        
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 9, minor: 8, patch: 7, prerelease: ""))     { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 6, minor: 5, patch: 4, prerelease: " "))    { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 3, minor: 2, patch: 1, prerelease: "+"))    { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 0, minor: 9, patch: 8, prerelease: "..."))  { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 4, minor: 3, patch: 2, prerelease: ".c."))  { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 1, minor: 0, patch: 9, prerelease: "测试版")) { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 8, minor: 7, patch: 6, prerelease: "00"))   { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 5, minor: 4, patch: 3, prerelease: "0123")) { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 0, minor: 1, patch: 2, buildMetadata: ""))    { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 3, minor: 4, patch: 5, buildMetadata: " "))   { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 6, minor: 7, patch: 8, buildMetadata: "+"))   { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 9, minor: 0, patch: 1, buildMetadata: "...")) { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 5, minor: 6, patch: 7, buildMetadata: ".c.")) { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
        XCTAssertThrowsError(try SymbolGraph.SemanticVersion(major: 8, minor: 9, patch: 0, buildMetadata: "🙃")) { XCTAssertTrue($0 is SymbolGraph.SemanticVersionError) }
    }
    
    func testInitializationFromOnlyVersionCoreComponents() {
        let version1 = SymbolGraph.SemanticVersion(0, 0, 0)
        XCTAssertEqual(version1.major, 0)
        XCTAssertEqual(version1.minor, 0)
        XCTAssertEqual(version1.patch, 0)
        XCTAssertEqual(version1.prereleaseIdentifiers, [])
        XCTAssertEqual(version1.buildMetadataIdentifiers, [])
        
        let version2 = SymbolGraph.SemanticVersion(3, 2, 1)
        XCTAssertEqual(version2.major, 3)
        XCTAssertEqual(version2.minor, 2)
        XCTAssertEqual(version2.patch, 1)
        XCTAssertEqual(version2.prereleaseIdentifiers, [])
        XCTAssertEqual(version2.buildMetadataIdentifiers, [])
    }
}
