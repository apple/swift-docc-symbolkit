/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import XCTest
@testable import SymbolKit

final class SemanticsTests: XCTestCase {
    func testDenotingStableRelease() throws {
        let stableVersions: [SymbolGraph.SemanticVersion] = [
            try .init(major: 1, minor: 0, patch: 0),
            try .init(major: 1, minor: 0, patch: 1),
            try .init(major: 1, minor: 2, patch: 3),
            try .init(major: 987, minor: 654, patch: 321),
            try .init(major: 3, minor: 2, patch: 1, buildMetadata: "abcde")
        ]
        
        for stableVersion in stableVersions {
            XCTAssertTrue(stableVersion.denotesStableRelease)
        }
        
        let unstableVersions: [SymbolGraph.SemanticVersion] = [
            try .init(major: 0, minor: 0, patch: 0),
            try .init(major: 0, minor: 0, patch: 1),
            try .init(major: 0, minor: 1, patch: 2),
            try .init(major: 0, minor: 9, patch: 8, prerelease: "gm"),
            try .init(major: 1, minor: 0, patch: 0, prerelease: "beta"),
            try .init(major: 9, minor: 9, patch: 9, prerelease: "alpha", buildMetadata: "xyz")
        ]
        
        for unstableVersion in unstableVersions {
            XCTAssertFalse(unstableVersion.denotesStableRelease)
        }
    }
    
    func testDenotingPrerelease() throws {
        let prereleaseVersions: [SymbolGraph.SemanticVersion] = [
            try .init(major: 0, minor: 0, patch: 0, prerelease: "asd"),
            try .init(major: 0, minor: 0, patch: 1, prerelease: "fgh"),
            try .init(major: 0, minor: 1, patch: 0, prerelease: "jkl"),
            try .init(major: 0, minor: 9, patch: 8, prerelease: "qwe", buildMetadata: "rty"),
            try .init(major: 1, minor: 0, patch: 0, prerelease: "uio"),
            try .init(major: 1, minor: 2, patch: 3, prerelease: "zxc")
        ]
        
        for prereleaseVersion in prereleaseVersions {
            XCTAssertTrue(prereleaseVersion.denotesPrerelease)
        }
        
        let releaseVersions: [SymbolGraph.SemanticVersion] = [
            try .init(major: 0, minor: 0, patch: 0),
            try .init(major: 0, minor: 0, patch: 1),
            try .init(major: 0, minor: 1, patch: 0),
            try .init(major: 0, minor: 9, patch: 8, buildMetadata: "rty"),
            try .init(major: 1, minor: 0, patch: 0),
            try .init(major: 1, minor: 2, patch: 3),
            try .init(major: 0, minor: 0, patch: 0, buildMetadata: "-asd"),
            try .init(major: 0, minor: 0, patch: 1, buildMetadata: "-fgh"),
            try .init(major: 0, minor: 1, patch: 0, buildMetadata: "-jkl"),
            try .init(major: 0, minor: 9, patch: 8, buildMetadata: "-qwe-rty"),
            try .init(major: 1, minor: 0, patch: 0, buildMetadata: "-uio"),
            try .init(major: 1, minor: 2, patch: 3, buildMetadata: "-zxc")
        ]
        
        for releaseVersion in releaseVersions {
            XCTAssertFalse(releaseVersion.denotesPrerelease)
        }
    }
    
    func testDenotingSourceBreakableRelease() throws {
        let sortedBreakableVersions: [SymbolGraph.SemanticVersion] = [
            try .init(major: 0, minor: 0, patch: 0, prerelease: "123"),
            try .init(major: 0, minor: 0, patch: 0, prerelease: "abc"),
            try .init(major: 0, minor: 0, patch: 0),
            try .init(major: 0, minor: 0, patch: 1, prerelease: "456"),
            try .init(major: 0, minor: 0, patch: 1, prerelease: "def"),
            try .init(major: 0, minor: 0, patch: 1),
            try .init(major: 0, minor: 0, patch: 2, prerelease: "789"),
            try .init(major: 0, minor: 0, patch: 2, prerelease: "ghi"),
            try .init(major: 0, minor: 0, patch: 2),
            try .init(major: 0, minor: 1, patch: 0, prerelease: "876"),
            try .init(major: 0, minor: 1, patch: 0, prerelease: "jkl"),
            try .init(major: 0, minor: 1, patch: 0),
            try .init(major: 0, minor: 1, patch: 2, prerelease: "543"),
            try .init(major: 0, minor: 1, patch: 2, prerelease: "mno"),
            try .init(major: 0, minor: 1, patch: 2),
            try .init(major: 1, minor: 0, patch: 0, prerelease: "212"),
            try .init(major: 1, minor: 0, patch: 0, prerelease: "pqr"),
            try .init(major: 1, minor: 0, patch: 0),
            try .init(major: 2, minor: 0, patch: 0, prerelease: "345"),
            try .init(major: 2, minor: 0, patch: 0, prerelease: "stu"),
            try .init(major: 2, minor: 0, patch: 0),
            try .init(major: 3, minor: 4, patch: 5, prerelease: "678"),
            try .init(major: 3, minor: 4, patch: 5, prerelease: "vwx"),
            try .init(major: 3, minor: 4, patch: 5)
        ]
        
        for newVersionIndex in 1..<sortedBreakableVersions.count {
            for oldVersionIndex in 0..<newVersionIndex {
                let newVersion = sortedBreakableVersions[newVersionIndex]
                let oldVersion = sortedBreakableVersions[oldVersionIndex]
                XCTAssertTrue(newVersion.denotesSourceBreakableRelease(fromThatWith: oldVersion))
                XCTAssertFalse(newVersion.denotesSourceBreakableRelease(fromThatWith: newVersion))
                XCTAssertFalse(oldVersion.denotesSourceBreakableRelease(fromThatWith: oldVersion))
                XCTAssertFalse(oldVersion.denotesSourceBreakableRelease(fromThatWith: newVersion))
            }
        }
        
        let sourceStableVersionPairs: [(newVersion: SymbolGraph.SemanticVersion, oldVersion: SymbolGraph.SemanticVersion)] = [
            (try .init(major: 1, minor: 0, patch: 1), try .init(major: 1, minor: 0, patch: 0)),
            
            (try .init(major: 1, minor: 0, patch: 2), try .init(major: 1, minor: 0, patch: 0)),
            (try .init(major: 1, minor: 0, patch: 2), try .init(major: 1, minor: 0, patch: 1)),
            
            (try .init(major: 1, minor: 1, patch: 0), try .init(major: 1, minor: 0, patch: 0)),
            (try .init(major: 1, minor: 1, patch: 0), try .init(major: 1, minor: 0, patch: 0)),
            (try .init(major: 1, minor: 1, patch: 0), try .init(major: 1, minor: 0, patch: 1)),
            
            (try .init(major: 1, minor: 2, patch: 3), try .init(major: 1, minor: 0, patch: 0)),
            (try .init(major: 1, minor: 2, patch: 3), try .init(major: 1, minor: 0, patch: 0)),
            (try .init(major: 1, minor: 2, patch: 3), try .init(major: 1, minor: 0, patch: 1)),
            (try .init(major: 1, minor: 2, patch: 3), try .init(major: 1, minor: 1, patch: 0)),
        ]
        
        for sourceStableVersionPair in sourceStableVersionPairs {
            let newVersion = sourceStableVersionPair.newVersion
            let oldVersion = sourceStableVersionPair.oldVersion
            XCTAssertFalse(newVersion.denotesSourceBreakableRelease(fromThatWith: oldVersion))
        }
    }
}
