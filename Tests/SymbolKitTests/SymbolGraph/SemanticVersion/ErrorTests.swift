/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import XCTest
@testable import SymbolKit

final class ErrorTests: XCTestCase {
    func testEmptyIdentifiers() {
        // MARK: pre-release
        
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try .init(major: 0, minor: 1, patch: 2, prerelease: ""))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try .init(major: 1, minor: 2, patch: 3, prerelease: "."))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try .init(major: 2, minor: 3, patch: 4, prerelease: "alpha."))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try .init(major: 3, minor: 4, patch: 5, prerelease: ".beta"))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try .init(major: 4, minor: 5, patch: 6, prerelease: "123."))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try .init(major: 5, minor: 6, patch: 7, prerelease: ".456"))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try .init(major: 6, minor: 7, patch: 8, prerelease: "y2k."))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try .init(major: 7, minor: 8, patch: 9, prerelease: ".mp3"))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":9,"minor":7,"patch":5,"prerelease":""}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":8,"minor":6,"patch":4,"prerelease":"."}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":7,"minor":5,"patch":3,"prerelease":"gold."}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":6,"minor":4,"patch":2,"prerelease":".master"}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":5,"minor":3,"patch":1,"prerelease":"0."}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":4,"minor":2,"patch":0,"prerelease":".1"}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":3,"minor":1,"patch":9,"prerelease":"2001odyssey."}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":2,"minor":0,"patch":8,"prerelease":".av1"}"#.utf8)))

        // MARK: build metadata

        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try .init(major: 0, minor: 1, patch: 2, buildMetadata: ""))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try .init(major: 1, minor: 2, patch: 3, buildMetadata: "."))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try .init(major: 2, minor: 3, patch: 4, buildMetadata: "alpha."))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try .init(major: 3, minor: 4, patch: 5, buildMetadata: ".beta"))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try .init(major: 4, minor: 5, patch: 6, buildMetadata: "123."))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try .init(major: 5, minor: 6, patch: 7, buildMetadata: ".456"))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try .init(major: 6, minor: 7, patch: 8, buildMetadata: "y2k."))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try .init(major: 7, minor: 8, patch: 9, buildMetadata: ".mp3"))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":9,"minor":7,"patch":5,"buildMetadata":""}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":8,"minor":6,"patch":4,"buildMetadata":"."}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":7,"minor":5,"patch":3,"buildMetadata":"gold."}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":6,"minor":4,"patch":2,"buildMetadata":".master"}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":5,"minor":3,"patch":1,"buildMetadata":"0."}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":4,"minor":2,"patch":0,"buildMetadata":".1"}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":3,"minor":1,"patch":9,"buildMetadata":"2001odyssey."}"#.utf8)))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":2,"minor":0,"patch":8,"buildMetadata":".av1"}"#.utf8)))
    }
    
    func testEmptyIdentifierDiagnosticPrecedence() {
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try .init(major: 1, minor: 2, patch: 3, prerelease: "", buildMetadata: ""))
        assertThrowingEmptyIdentifierError(atPosition: .prerelease, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":1,"minor":2,"patch":3,"prerelease":"","buildMetadata":""}"#.utf8)))
        
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try .init(major: 1, minor: 2, patch: 3, prerelease: "4", buildMetadata: ""))
        assertThrowingEmptyIdentifierError(atPosition: .buildMetadata, whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":1,"minor":2,"patch":3,"prerelease":"4","buildMetadata":""}"#.utf8)))
    }
    
    func testNonAlphanumericCharacters() {
        //    MARK: pre-release
        
        assertThrowingNonAlphanumericCharacterError(atPosition: .prerelease, inIdentifier: "😛",           whenEvaluating: try .init(major: 9, minor: 8, patch: 7, prerelease: "😛"))
        assertThrowingNonAlphanumericCharacterError(atPosition: .prerelease, inIdentifier: "😝alpha",      whenEvaluating: try .init(major: 6, minor: 5, patch: 4, prerelease: "😝alpha.beta"))
        assertThrowingNonAlphanumericCharacterError(atPosition: .prerelease, inIdentifier: "beta😜",       whenEvaluating: try .init(major: 3, minor: 2, patch: 1, prerelease: "alpha.beta😜"))
        assertThrowingNonAlphanumericCharacterError(atPosition: .prerelease, inIdentifier: "pre🤪release", whenEvaluating: try .init(major: 0, minor: 9, patch: 8, prerelease: "pre🤪release.un🤨stable"))
        assertThrowingNonAlphanumericCharacterError(atPosition: .prerelease, inIdentifier: "🥳",     whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":5,"minor":4,"patch":3,"prerelease":"🥳"}"#.utf8)))
        assertThrowingNonAlphanumericCharacterError(atPosition: .prerelease, inIdentifier: "😏123",  whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":2,"minor":1,"patch":0,"prerelease":"😏123.456"}"#.utf8)))
        assertThrowingNonAlphanumericCharacterError(atPosition: .prerelease, inIdentifier: "456😒",  whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":1,"minor":2,"patch":3,"prerelease":"123.456😒"}"#.utf8)))
        assertThrowingNonAlphanumericCharacterError(atPosition: .prerelease, inIdentifier: "13😞37", whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":4,"minor":5,"patch":6,"prerelease":"13😞37.le😔et"}"#.utf8)))
        
        //    MARK: build metadata
        
        assertThrowingNonAlphanumericCharacterError(atPosition: .buildMetadata, inIdentifier: "😟",     whenEvaluating: try .init(major: 7, minor: 8, patch: 9, buildMetadata: "😟"))
        assertThrowingNonAlphanumericCharacterError(atPosition: .buildMetadata, inIdentifier: "😕abcd", whenEvaluating: try .init(major: 0, minor: 1, patch: 2, buildMetadata: "😕abcd.efgh"))
        assertThrowingNonAlphanumericCharacterError(atPosition: .buildMetadata, inIdentifier: "mnop🙁", whenEvaluating: try .init(major: 3, minor: 4, patch: 5, buildMetadata: "ijkl.mnop🙁"))
        assertThrowingNonAlphanumericCharacterError(atPosition: .buildMetadata, inIdentifier: "qr☹️st", whenEvaluating: try .init(major: 6, minor: 7, patch: 8, buildMetadata: "qr☹️st.uv😣wx"))
        assertThrowingNonAlphanumericCharacterError(atPosition: .buildMetadata, inIdentifier: "😭",       whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":9,"minor":8,"patch":7,"buildMetadata":"😭"}"#.utf8)))
        assertThrowingNonAlphanumericCharacterError(atPosition: .buildMetadata, inIdentifier: "😤1a2",    whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":6,"minor":5,"patch":4,"buildMetadata":"😤1a2.b3c"}"#.utf8)))
        assertThrowingNonAlphanumericCharacterError(atPosition: .buildMetadata, inIdentifier: "e6f😠",    whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":3,"minor":2,"patch":1,"buildMetadata":"4d5.e6f😠"}"#.utf8)))
        assertThrowingNonAlphanumericCharacterError(atPosition: .buildMetadata, inIdentifier: "7g8😡h9i", whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":0,"minor":9,"patch":8,"buildMetadata":"7g8😡h9i.10j🤬11k"}"#.utf8)))
    }
    
    func testNonNumericCharacters() {
        //    MARK: pre-release
        
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 9, minor: 8, patch: 7, prerelease: "abc123"))
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 6, minor: 5, patch: 4, prerelease: "456def"))
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 3, minor: 2, patch: 1, prerelease: "7g8h9i"))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":1,"minor":0,"patch":9,"prerelease":"stu901"}"#.utf8)))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":8,"minor":7,"patch":6,"prerelease":"234vwx"}"#.utf8)))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":5,"minor":4,"patch":3,"prerelease":"5y6z7a"}"#.utf8)))
        
        //    MARK: build metadata
        
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 2, minor: 1, patch: 0, buildMetadata: "bcd890"))
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 9, minor: 8, patch: 7, buildMetadata: "123efg"))
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 6, minor: 5, patch: 4, buildMetadata: "h4i5j6"))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":4,"minor":3,"patch":2,"buildMetadata":"tuv678"}"#.utf8)))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":1,"minor":0,"patch":9,"buildMetadata":"901wxy"}"#.utf8)))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":8,"minor":7,"patch":6,"buildMetadata":"z2a3b4"}"#.utf8)))
    }
    
    func testLeadingZeros() {
        //    MARK: pre-release
        
        assertThrowingLeadingZerosError(atPosition: .prerelease, inIdentifier: "0246", whenEvaluating: try .init(major: 1, minor: 3, patch: 5, prerelease: "0246"))
        assertThrowingLeadingZerosError(atPosition: .prerelease, inIdentifier: "0068", whenEvaluating: try .init(major: 3, minor: 5, patch: 7, prerelease: "0068"))
        assertThrowingLeadingZerosError(atPosition: .prerelease, inIdentifier: "0000", whenEvaluating: try .init(major: 5, minor: 7, patch: 9, prerelease: "0000"))
        assertThrowingLeadingZerosError(atPosition: .prerelease, inIdentifier: "0654", whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":9,"minor":8,"patch":7,"prerelease":"0654"}"#.utf8)))
        assertThrowingLeadingZerosError(atPosition: .prerelease, inIdentifier: "0065", whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":9,"minor":8,"patch":7,"prerelease":"0065"}"#.utf8)))
        assertThrowingLeadingZerosError(atPosition: .prerelease, inIdentifier: "0000", whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":9,"minor":8,"patch":7,"prerelease":"0000"}"#.utf8)))
        
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 2, minor: 3, patch: 4, prerelease: "0"))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":8,"minor":9,"patch":1,"prelease":"0"}"#.utf8)))
        
        //    MARK: build metadata
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 2, minor: 3, patch: 4, buildMetadata: "0567"))
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 8, minor: 9, patch: 1, buildMetadata: "0023"))
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 4, minor: 5, patch: 6, buildMetadata: "0000"))
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 7, minor: 8, patch: 9, buildMetadata: "0"))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":9,"minor":1,"patch":2,"buildMetadata":"0345"}"#.utf8)))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":6,"minor":7,"patch":8,"buildMetadata":"0091"}"#.utf8)))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":2,"minor":3,"patch":4,"buildMetadata":"0000"}"#.utf8)))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":5,"minor":6,"patch":7,"buildMetadata":"0"}"#.utf8)))
    }
    
    func testOversizedNumericValues() {
        func sum(_ summand1: String, _ summand2: String) -> Substring {
            let paddedSummandLength = max(summand1.count, summand2.count) + 1
            let paddedSummand1 = zeroPadded(summand1, toLength: paddedSummandLength)
            let paddedSummand2 = zeroPadded(summand2, toLength: paddedSummandLength)
            
            var result: [Character] = []
            result.reserveCapacity(paddedSummandLength)
            
            var carry: Int8 = 0
            
            for (digit1, digit2) in zip(paddedSummand1.reversed(), paddedSummand2.reversed()) {
                let digit1 = Int8(String(digit1))!
                let digit2 = Int8(String(digit2))!
                let columnSum = digit1 + digit2 + carry
                carry = columnSum > 9 ? 1 : 0
                result.append(String(columnSum).last!)
            }
            
            return Substring(result[...result.lastIndex(where: { $0 != "0" })!].reversed())
            
            func zeroPadded(_ number: String, toLength paddedLength: Int) -> [Character] {
                let paddingLength = paddedLength - number.count
                var paddedNumber = [Character](repeating: "0", count: paddingLength)
                paddedNumber.reserveCapacity(paddedLength)
                paddedNumber.append(contentsOf: number)
                return paddedNumber
            }
        }
        
        //    MARK: infrastructure sanity check
        
        XCTAssertEqual(sum("123", "456"), "579")
        XCTAssertEqual(sum("999", "999"), "1998")
        XCTAssertEqual(sum("4545", "4545"), "9090")
        XCTAssertEqual(sum("123456789", "98765"), "123555554")
        XCTAssertEqual(sum("111111111111111111111111111111", "111111111111111111111111111111"), "222222222222222222222222222222")    //    30 digits in each
        XCTAssertEqual(sum("111111111111111111111111111111", "000000000011111111112222222222"), "111111111122222222223333333333")
        XCTAssertEqual(sum("999999999999999999999999999999", "999999999999999999999999999999"), "1999999999999999999999999999998")    //    30 digits in each
        XCTAssertEqual(sum("\(UInt64.max)", "1"), "18446744073709551616")
        XCTAssertEqual(sum("\(UInt64.max)", "\(Int32.max)"), "18446744075857035262")
        XCTAssertEqual(sum("\(UInt64.max)", "\(UInt64.max)"), "36893488147419103230")
        
        //    MARK: pre-release
        
        assertThrowingOversizedValueError(atPosition: .prerelease, inIdentifier: sum("\(UInt.max)", "1"),    whenEvaluating: try .init(major: 1, minor: 3, patch: 5, prerelease: String(sum("\(UInt.max)", "1"))))
        assertThrowingOversizedValueError(atPosition: .prerelease, inIdentifier: "8\(UInt.max)",             whenEvaluating: try .init(major: 2, minor: 4, patch: 6, prerelease: "8\(UInt.max)"))
        assertThrowingOversizedValueError(atPosition: .prerelease, inIdentifier: "\(UInt.max)\(UInt.max)",   whenEvaluating: try .init(major: 3, minor: 5, patch: 7, prerelease: "\(UInt.max)\(UInt.max)"))
        assertThrowingOversizedValueError(atPosition: .prerelease, inIdentifier: sum("\(UInt.max)", "1"),    whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":9,"minor":8,"patch":7,"prerelease":"\#(sum("\(UInt.max)", "1"))"}"#.utf8)))
        assertThrowingOversizedValueError(atPosition: .prerelease, inIdentifier: "3\(UInt.max)",             whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":6,"minor":5,"patch":4,"prerelease":"3\#(UInt.max)"}"#.utf8)))
        assertThrowingOversizedValueError(atPosition: .prerelease, inIdentifier: "\(UInt.max)\(UInt64.max)", whenEvaluating: try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":2,"minor":1,"patch":0,"prerelease":"\#(UInt.max)\#(UInt64.max)"}"#.utf8)))
        
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: "\(UInt.max)"))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":7,"minor":8,"patch":9,"prerelease":"\#(UInt.max)"}"#.utf8)))
        
        //    MARK: build metadata
        
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 1, minor: 2, patch: 3, buildMetadata: "\(UInt.max)"))
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 4, minor: 5, patch: 6, buildMetadata: String(sum("\(UInt.max)", "1"))))
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 7, minor: 8, patch: 9, buildMetadata: "\(UInt.max)0"))
        XCTAssertNoThrow(try SymbolGraph.SemanticVersion(major: 1, minor: 2, patch: 3, buildMetadata: "\(UInt.max)\(Int.max)"))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":7,"minor":8,"patch":9,"buildMetadata":"\#(UInt.max)"}"#.utf8)))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":0,"minor":1,"patch":2,"buildMetadata":"\#(sum("\(UInt.max)", "1"))"}"#.utf8)))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":3,"minor":4,"patch":5,"buildMetadata":"\#(UInt.max)6"}"#.utf8)))
        XCTAssertNoThrow(try JSONDecoder().decode(SymbolGraph.SemanticVersion.self, from: Data(#"{"major":7,"minor":8,"patch":9,"buildMetadata":"\#(UInt.max)\#(UInt.max)"}"#.utf8)))
    }
        
    //    TODO: Add tests for the precedence of error-throwing.
    
    func assertThrowingEmptyIdentifierError(
        atPosition position: SymbolGraph.SemanticVersionError.IdentifierPosition,
        whenEvaluating expression: @autoclosure () throws -> SymbolGraph.SemanticVersion
    ) {
        let positionString: String
		switch position {
		case .major:         positionString = "major"
		case .minor:         positionString = "minor"
		case .patch:         positionString = "patch"
		case .prerelease:    positionString = "prerelease"
		case .buildMetadata: positionString = "buildMetadata"
		}
        XCTAssertThrowsError(
            try expression(),
            "'SymbolGraph.SemanticVersionError.emptyIdentifier(position: .\(positionString))' should've been thrown, but no error is thrown"
        ) { error in
            guard let error = error as? SymbolGraph.SemanticVersionError, case .emptyIdentifier(position: position) = error else {
                XCTFail(#"'SymbolGraph.SemanticVersionError.emptyIdentifier(position: .\#(positionString))' should've been thrown, but a different error is thrown instead; error description: "\#(error)""#)
                return
            }
            let positionDescription: String
			switch position {
			case .major:         positionDescription = "major version number"
			case .minor:         positionDescription = "minor version number"
			case .patch:         positionDescription = "patch version number"
			case .prerelease:    positionDescription = "pre-release"
			case .buildMetadata: positionDescription = "build metadata"
			}
            XCTAssertEqual(
                error.description,
                "semantic version \(positionDescription) identifier cannot be empty"
            )
        }
    }
    
    func assertThrowingNonAlphanumericCharacterError(
        atPosition position: SymbolGraph.SemanticVersionError.AlphanumericIdentifierPosition,
        inIdentifier identifier: Substring,
        whenEvaluating expression: @autoclosure () throws -> SymbolGraph.SemanticVersion
    ) {
        let positionString: String
		switch position {
		case .prerelease:    positionString = "prerelease"
		case .buildMetadata: positionString = "buildMetadata"
		}
        XCTAssertThrowsError(
            try expression(),
            "'SymbolGraph.SemanticVersionError.invalidCharacterInIdentifier(\(identifier), position: .\(positionString))' should've been thrown, but no error is thrown"
        ) { error in
            guard let error = error as? SymbolGraph.SemanticVersionError, case .invalidCharacterInIdentifier(identifier, position: position) = error else {
                XCTFail((#"'SymbolGraph.SemanticVersionError.invalidCharacterInIdentifier(\#(identifier), position: .\#(positionString))' should've been thrown, but a different error is thrown instead; error description: "\#(error)""#))
                return
            }
            let positionDescription: String
			switch position {
			case .prerelease:    positionDescription = "pre-release"
			case .buildMetadata: positionDescription = "build metadata"
			}
            XCTAssertEqual(
                error.description,
                "semantic version \(positionDescription) identifier '\(identifier)' cannot contain characters other than ASCII alphanumerics and hyphen-minus ([0-9A-Za-z-])"
            )
        }
    }
    
    func assertThrowingNonNumericCharacterError(
        atPosition position: SymbolGraph.SemanticVersionError.NumericIdentifierPosition,
        inIdentifier identifier: Substring,
        whenEvaluating expression: @autoclosure () throws -> SymbolGraph.SemanticVersion
    ) {
        let positionString: String
		switch position {
		case .major: positionString = "major"
		case .minor: positionString = "minor"
		case .patch: positionString = "patch"
		case .prerelease: XCTFail("pre-release identifier with non-numeric characters should be regarded as alpha-numeric identifier"); positionString = "prerelease"
		}
        XCTAssertThrowsError(
            try expression(),
            "'SymbolGraph.SemanticVersionError.invalidCharacterInIdentifier(\(identifier), position: .\(positionString))' should've been thrown, but no error is thrown"
        ) { error in
            guard let error = error as? SymbolGraph.SemanticVersionError, case .invalidNumericIdentifier(identifier, position: position, errorKind: .nonNumericCharacter) = error else {
                XCTFail((#"'SymbolGraph.SemanticVersionError.invalidNumericIdentifier(\#(identifier), position: \#(positionString), errorKind: .nonNumericCharacter)' should've been thrown, but a different error is thrown instead; error description: "\#(error)""#))
                return
            }
            let positionDescription: String
			switch position {
			case .major: positionDescription = "major version number"
			case .minor: positionDescription = "minor version number"
			case .patch: positionDescription = "patch version number"
			case .prerelease: XCTFail("pre-release identifier with non-numeric characters should be regarded as alpha-numeric identifier"); positionDescription = "pre-release numeric"
			}
            XCTAssertEqual(
                error.description,
                "semantic version \(positionDescription) identifier '\(identifier)' cannot contain non-numeric characters"
            )
        }
    }
    
    func assertThrowingLeadingZerosError(
        atPosition position: SymbolGraph.SemanticVersionError.NumericIdentifierPosition,
        inIdentifier identifier: Substring,
        whenEvaluating expression: @autoclosure () throws -> SymbolGraph.SemanticVersion
    ) {
        let positionString: String
		switch position {
		case .major:      positionString = "major"
		case .minor:      positionString = "minor"
		case .patch:      positionString = "patch"
		case .prerelease: positionString = "prerelease"
		}
        XCTAssertThrowsError(
            try expression(),
            "'SymbolGraph.SemanticVersionError.invalidCharacterInIdentifier(\(identifier), position: .\(positionString))' should've been thrown, but no error is thrown"
        ) { error in
            guard let error = error as? SymbolGraph.SemanticVersionError, case .invalidNumericIdentifier(identifier, position: position, errorKind: .leadingZeros) = error else {
                XCTFail((#"'SymbolGraph.SemanticVersionError.invalidNumericIdentifier(\#(identifier), position: \#(positionString), errorKind: .leadingZeros)' should've been thrown, but a different error is thrown instead; error description: "\#(error)""#))
                return
            }
			let positionDescription: String
			switch position {
			case .major:      positionDescription = "major version number"
			case .minor:      positionDescription = "minor version number"
			case .patch:      positionDescription = "patch version number"
			case .prerelease: positionDescription = "pre-release numeric"
			}
            XCTAssertEqual(
                error.description,
                "semantic version \(positionDescription) identifier '\(identifier)' cannot contain leading '0'"
            )
        }
    }
    
    func assertThrowingOversizedValueError(
        atPosition position: SymbolGraph.SemanticVersionError.NumericIdentifierPosition,
        inIdentifier identifier: Substring,
        whenEvaluating expression: @autoclosure () throws -> SymbolGraph.SemanticVersion
    ) {
		let positionString: String
		switch position {
		case .major:      positionString = "major"
		case .minor:      positionString = "minor"
		case .patch:      positionString = "patch"
		case .prerelease: positionString = "prerelease"
		}
        XCTAssertThrowsError(
            try expression(),
            "'SymbolGraph.SemanticVersionError.invalidCharacterInIdentifier(\(identifier), position: .\(positionString))' should've been thrown, but no error is thrown"
        ) { error in
            guard let error = error as? SymbolGraph.SemanticVersionError, case .invalidNumericIdentifier(identifier, position: position, errorKind: .oversizedValue) = error else {
                XCTFail((#"'SymbolGraph.SemanticVersionError.invalidNumericIdentifier(\#(identifier), position: \#(positionString), errorKind: .oversizedValue)' should've been thrown, but a different error is thrown instead; error description: "\#(error)""#))
                return
            }
            let positionDescription: String
			switch position {
			case .major:      positionDescription = "major version number"
			case .minor:      positionDescription = "minor version number"
			case .patch:      positionDescription = "patch version number"
			case .prerelease: positionDescription = "pre-release numeric"
			}
            XCTAssertEqual(
                error.description,
                "semantic version \(positionDescription) identifier '\(identifier)' cannot be larger than 'UInt.max'"
            )
        }
    }
}
