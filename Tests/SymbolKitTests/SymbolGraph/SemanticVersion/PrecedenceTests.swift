/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import XCTest
@testable import SymbolKit

final class PrecedenceTests: XCTestCase {
    func assert(_ version1: SymbolGraph.SemanticVersion, precedes version2: SymbolGraph.SemanticVersion) {
        XCTAssertLessThan(version1, version2)
        XCTAssertLessThanOrEqual(version1, version2)
        XCTAssertGreaterThan(version2, version1)
        XCTAssertGreaterThanOrEqual(version2, version1)
        XCTAssertNotEqual(version1, version2)
        XCTAssertNotEqual(version2, version1)
        // test false paths
        XCTAssertFalse(version1 > version2)
        XCTAssertFalse(version1 >= version2)
        XCTAssertFalse(version2 < version1)
        XCTAssertFalse(version2 <= version1)
    }
    
    func assert(_ version1: SymbolGraph.SemanticVersion, equals version2: SymbolGraph.SemanticVersion) {
        XCTAssertEqual(version1, version2)
        XCTAssertEqual(version2, version1)
        XCTAssertLessThanOrEqual(version1, version2)
        XCTAssertLessThanOrEqual(version1, version2)
        XCTAssertGreaterThanOrEqual(version1, version2)
        XCTAssertGreaterThanOrEqual(version2, version1)
        // test false paths
        XCTAssertFalse(version1 != version2)
        XCTAssertFalse(version2 != version1)
        XCTAssertFalse(version1 < version2)
        XCTAssertFalse(version2 < version1)
        XCTAssertFalse(version1 > version2)
        XCTAssertFalse(version2 > version1)
    }
    
    func testVersionCorePrecedence() throws {
        assert(try .init(major: 0, minor: 0, patch: 0), precedes: try .init(major: 0, minor: 0, patch: 1))
        assert(try .init(major: 0, minor: 0, patch: 0), precedes: try .init(major: 0, minor: 1, patch: 0))
        assert(try .init(major: 0, minor: 0, patch: 0), precedes: try .init(major: 1, minor: 0, patch: 0))
        assert(try .init(major: 1, minor: 2, patch: 3), precedes: try .init(major: 1, minor: 2, patch: 4))
        assert(try .init(major: 1, minor: 2, patch: 3), precedes: try .init(major: 1, minor: 3, patch: 3))
        assert(try .init(major: 1, minor: 2, patch: 3), precedes: try .init(major: 2, minor: 2, patch: 3))
        
        assert(try .init(major: 0, minor: 0, patch: 0), equals: try .init(major: 0, minor: 0, patch: 0))
        assert(try .init(major: 1, minor: 2, patch: 3), equals: try .init(major: 1, minor: 2, patch: 3))
        assert(try .init(major: 3, minor: 2, patch: 1), equals: try .init(major: 3, minor: 2, patch: 1))
    }
    
    func testPrereleasePrecedence() throws {
        // Test cases include different combinations of numeric and alpha-numeric identifiers, with different precedences, and try to capture edge cases.
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 4))
        assert(try .init(major: 1, minor: 2, patch: 2),                     precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"))
        assert(try .init(major: 1, minor: 2, patch: 3),                     precedes: try .init(major: 1, minor: 2, patch: 4, prerelease: "beta"))
        assert(try .init(major: 1, minor: 2, patch: 3),                     precedes: try .init(major: 1, minor: 3, patch: 3, prerelease: "beta"))
        assert(try .init(major: 1, minor: 2, patch: 3),                     precedes: try .init(major: 2, minor: 2, patch: 3, prerelease: "beta"))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"),  precedes: try .init(major: 1, minor: 2, patch: 4, prerelease: "beta"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha"), precedes: try .init(major: 1, minor: 2, patch: 4, prerelease: "beta"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"),  precedes: try .init(major: 1, minor: 2, patch: 4, prerelease: "alpha"))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "betax"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta-x"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta1"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta-1"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta1x"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta-1x"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "betax1"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta-x1"))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta.x"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta.1"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta.1x"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta.x1"))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "a"),        precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha"),    precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha42"),  precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha-42"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha.42"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "1bcd"), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abcd"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abcd"), precedes: try .init(major: 4, minor: 5, patch: 7, prerelease: "1bcd"))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "456"),       precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "456.alpha"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha"))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123"),         precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "987"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123"),         precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "124"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123.456.789"), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "123.456.987"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123.456.789"), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "321.111.111"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "9.9.9.9.9.9"), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "10"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "9.9.9.9.9.9"), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "10.0.0.0.0"))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.def.123"), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.def.789"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.def.789"), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.ghi.123"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123.def-ghi"), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "789.abc.def"))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "987"),              precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "123a"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "987654321"),        precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "0a"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "999999999"),        precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "0a"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "999999999.zzz.zz"), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "0a"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.def.123"),      precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.def.ghi"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.987.ghi"),      precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.123def.123"))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc-123def-123"), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc-987-ghi"))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "0a"), precedes: try .init(major: 4, minor: 5, patch: 7, prerelease: "987"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "0a"), precedes: try .init(major: 4, minor: 6, patch: 6, prerelease: "987"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "0a"), precedes: try .init(major: 5, minor: 5, patch: 6, prerelease: "987"))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"),    equals: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123abc"),  equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "123abc"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123-abc"), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "123-abc"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123.abc"), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "123.abc"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc123"),  equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc123"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc-123"), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc-123"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.123"), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.123"))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc123.123abc.123-abc.abc-123"), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc123.123abc.123-abc.abc-123"))
    }
    
    func testBuildMetadataPrecedence() throws {
        
        // In addition to hardcoded different combinations of numeric and alpha-numeric identifiers, with different precedences, some build metadata is randomly generated at each run of the test.
        
        var randomBuildMetadata: String {
            let lexicon = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-."
            let length = UInt8.random(in: 1...(.max))    //    don't be too long
            var characters: [Character] = []
            characters.reserveCapacity(Int(length))
            for position in 1...length {
                if let lastCharacter = characters.last, lastCharacter != ".", position != length {
                    characters.append(lexicon.randomElement()!)
                } else {
                    characters.append(lexicon.dropLast().randomElement()!)
                }
            }
            return String(characters)
        }
        
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "abc"),    precedes: try .init(major: 0, minor: 0, patch: 1, buildMetadata: "abc"))
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "abc"),    precedes: try .init(major: 0, minor: 0, patch: 1, buildMetadata: "bcd"))
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "bcd"),    precedes: try .init(major: 0, minor: 0, patch: 1, buildMetadata: "abc"))
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "123"),    precedes: try .init(major: 0, minor: 1, patch: 0, buildMetadata: "123"))
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "123"),    precedes: try .init(major: 0, minor: 1, patch: 0, buildMetadata: "234"))
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "234"),    precedes: try .init(major: 0, minor: 1, patch: 0, buildMetadata: "123"))
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "1a2b3c"), precedes: try .init(major: 1, minor: 0, patch: 0, buildMetadata: "1a2b3c"))
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "1a2b3c"), precedes: try .init(major: 1, minor: 0, patch: 0, buildMetadata: "3c2b1a"))
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "3c2b1a"), precedes: try .init(major: 1, minor: 0, patch: 0, buildMetadata: "1a2b3c"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "a1b2c3"), precedes: try .init(major: 1, minor: 2, patch: 4, buildMetadata: "a1b2c3"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "a1b2c3"), precedes: try .init(major: 1, minor: 2, patch: 4, buildMetadata: "c3b2a1"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "c3b2a1"), precedes: try .init(major: 1, minor: 2, patch: 4, buildMetadata: "a1b2c3"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "1-2-3"),  precedes: try .init(major: 1, minor: 3, patch: 3, buildMetadata: "1-2-3"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "1-2-3"),  precedes: try .init(major: 1, minor: 3, patch: 3, buildMetadata: "3-2-1"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "3-2-1"),  precedes: try .init(major: 1, minor: 3, patch: 3, buildMetadata: "1-2-3"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "1.2.3"),  precedes: try .init(major: 2, minor: 2, patch: 3, buildMetadata: "1.2.3"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "1.2.3"),  precedes: try .init(major: 2, minor: 2, patch: 3, buildMetadata: "2.3.4"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "2.3.4"),  precedes: try .init(major: 2, minor: 2, patch: 3, buildMetadata: "1.2.3"))
        
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "a-b-c"), equals: try .init(major: 0, minor: 0, patch: 0, buildMetadata: "a-b-c"))
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "a-b-c"), equals: try .init(major: 0, minor: 0, patch: 0, buildMetadata: "c-b-a"))
        assert(try .init(major: 0, minor: 0, patch: 0, buildMetadata: "c-b-a"), equals: try .init(major: 0, minor: 0, patch: 0, buildMetadata: "a-b-c"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "a.b.c"), equals: try .init(major: 1, minor: 2, patch: 3, buildMetadata: "a.b.c"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "a.b.c"), equals: try .init(major: 1, minor: 2, patch: 3, buildMetadata: "c.b.a"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: "c.b.a"), equals: try .init(major: 1, minor: 2, patch: 3, buildMetadata: "a.b.c"))
        assert(try .init(major: 3, minor: 2, patch: 1, buildMetadata: "a-1.b-2.c-3"), equals: try .init(major: 3, minor: 2, patch: 1, buildMetadata: "a-1.b-2.c-3"))
        assert(try .init(major: 3, minor: 2, patch: 1, buildMetadata: "a-1.b-2.c-3"), equals: try .init(major: 3, minor: 2, patch: 1, buildMetadata: "3.c-2.b-1.a"))
        assert(try .init(major: 3, minor: 2, patch: 1, buildMetadata: "3.c-2.b-1.a"), equals: try .init(major: 3, minor: 2, patch: 1, buildMetadata: "a-1.b-2.c-3"))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: "---"),   precedes: try .init(major: 1, minor: 2, patch: 3, buildMetadata: "---"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: "-"),     precedes: try .init(major: 1, minor: 2, patch: 3, buildMetadata: "---"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: "---"),   precedes: try .init(major: 1, minor: 2, patch: 3, buildMetadata: "-"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: "-.-"),   precedes: try .init(major: 1, minor: 2, patch: 4, buildMetadata: "-.-"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: "-.-.-"), precedes: try .init(major: 1, minor: 2, patch: 4, buildMetadata: "-.-"))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: "-.-"),   precedes: try .init(major: 1, minor: 2, patch: 4, buildMetadata: "-.-.-"))
        assert(try .init(major: 1, minor: 2, patch: 2, buildMetadata: "000"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: "000"))
        assert(try .init(major: 1, minor: 2, patch: 2, buildMetadata: "000"), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: "0"))
        assert(try .init(major: 1, minor: 2, patch: 2, buildMetadata: "0"),   precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: "000"))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 4, prerelease: "beta", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 3, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, buildMetadata: randomBuildMetadata), precedes: try .init(major: 2, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata))

        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta",  buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 4, prerelease: "beta",  buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 4, prerelease: "beta",  buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta",  buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 4, prerelease: "alpha", buildMetadata: randomBuildMetadata))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "betax",   buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta-x",  buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta1",   buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta-1",  buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta1x",  buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta-1x", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "betax1",  buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta-x1", buildMetadata: randomBuildMetadata))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta.x",  buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta.1",  buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta.1x", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta.x1", buildMetadata: randomBuildMetadata))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "a",        buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha",    buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha42",  buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha-42", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha.42", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "1bcd", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abcd", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abcd", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 7, prerelease: "1bcd", buildMetadata: randomBuildMetadata))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "456",       buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "456.alpha", buildMetadata: randomBuildMetadata), precedes: try .init(major: 1, minor: 2, patch: 3, prerelease: "alpha", buildMetadata: randomBuildMetadata))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "987", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "124", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123.456.789", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "123.456.987", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123.456.789", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "321.111.111", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "9.9.9.9.9.9", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "10",         buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "9.9.9.9.9.9", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "10.0.0.0.0", buildMetadata: randomBuildMetadata))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.def.123", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.def.789", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.def.789", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.ghi.123", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123.def-ghi", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "789.abc.def", buildMetadata: randomBuildMetadata))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "987",       buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "123a", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "987654321", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "0a",   buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "999999999", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "0a",   buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "999999999.zzzzz.zzzzz", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "0a", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.def.123", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.def.ghi",    buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.987.ghi", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.123def.123", buildMetadata: randomBuildMetadata))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc-123def-123", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc-987-ghi", buildMetadata: randomBuildMetadata))
        
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "0a", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 5, patch: 7, prerelease: "987", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "0a", buildMetadata: randomBuildMetadata), precedes: try .init(major: 4, minor: 6, patch: 6, prerelease: "987", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "0a", buildMetadata: randomBuildMetadata), precedes: try .init(major: 5, minor: 5, patch: 6, prerelease: "987", buildMetadata: randomBuildMetadata))
        
        assert(try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata), equals: try .init(major: 1, minor: 2, patch: 3, prerelease: "beta", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123abc",  buildMetadata: randomBuildMetadata), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "123abc",  buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123-abc", buildMetadata: randomBuildMetadata), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "123-abc", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "123.abc", buildMetadata: randomBuildMetadata), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "123.abc", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc123",  buildMetadata: randomBuildMetadata), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc123",  buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc-123", buildMetadata: randomBuildMetadata), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc-123", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.123", buildMetadata: randomBuildMetadata), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc.123", buildMetadata: randomBuildMetadata))
        assert(try .init(major: 4, minor: 5, patch: 6, prerelease: "abc123.123abc.123-abc.abc-123", buildMetadata: randomBuildMetadata), equals: try .init(major: 4, minor: 5, patch: 6, prerelease: "abc123.123abc.123-abc.abc-123", buildMetadata: randomBuildMetadata))
    }
}
