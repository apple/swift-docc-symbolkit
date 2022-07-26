/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest
import Foundation
@testable import SymbolKit

class SymbolKindTests: XCTestCase {
    
    func testKindParsing() throws {
        var kind: SymbolGraph.Symbol.KindIdentifier

        // Verify basic parsing of old style identifier is working.
        XCTAssert(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("swift.func"))
        kind = SymbolGraph.Symbol.KindIdentifier(identifier: "swift.func")
        XCTAssertEqual(kind, .func)
        XCTAssertEqual(kind.identifier, "func")

        // Verify new language-agnostic type is recognized.
        XCTAssert(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("func"))
        kind = SymbolGraph.Symbol.KindIdentifier(identifier: "func")
        XCTAssertEqual(kind, .func)
        XCTAssertEqual(kind.identifier, "func")

        // Verify a bare language is not recognized.
        XCTAssertFalse(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("swift"))
        kind = SymbolGraph.Symbol.KindIdentifier(identifier: "swift")
        XCTAssertEqual(kind.identifier, "swift")

        // Verify if nothing is recognized, identifier and name is still there.
        XCTAssertFalse(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("swift.madeupapi"))
        kind = SymbolGraph.Symbol.KindIdentifier(identifier: "swift.madeupapi")
        XCTAssertEqual(kind.identifier, "swift.madeupapi")
        
        // Verify a registered, previously unknown identifier is recognized.
        let custom = SymbolGraph.Symbol.KindIdentifier(rawValue: "custom")
        SymbolGraph.Symbol.KindIdentifier.register(custom)
        
        XCTAssert(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("swift.custom"))
        kind = SymbolGraph.Symbol.KindIdentifier(identifier: "swift.custom")
        XCTAssertEqual(kind, custom)
        XCTAssertEqual(kind.identifier, "custom")

        // Verify a registered, previously unknown identifier is recognized if
        // used in a language-agnostic way.
        XCTAssert(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("custom"))
        kind = SymbolGraph.Symbol.KindIdentifier(identifier: "custom")
        XCTAssertEqual(kind, custom)
        XCTAssertEqual(kind.identifier, "custom")
        
        // Verify an unknown identifier is parsed correctly if it is
        // registered with the deocder.
        let otherCustom = SymbolGraph.Symbol.KindIdentifier(rawValue: "other.custom")
        let decoder = JSONDecoder()
        decoder.register(symbolKinds: otherCustom)
        
        XCTAssertFalse(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("swift.other.custom"))
        kind = try decoder.decode(SymbolGraph.Symbol.KindIdentifier.self, from: "\"swift.other.custom\"".data(using: .utf8)!)
        XCTAssertEqual(kind, otherCustom)
        XCTAssertEqual(kind.identifier, "other.custom")
    }
    
    func testAllCasesWithCustomIdentifiers() throws {
        let registeredOnStaticContext = SymbolGraph.Symbol.KindIdentifier(rawValue: "custom.registeredOnStaticContext")
        SymbolGraph.Symbol.KindIdentifier.register(registeredOnStaticContext)
        
        let registeredOnDecoder = SymbolGraph.Symbol.KindIdentifier(rawValue: "custom.registeredOnDecoder")
        JSONDecoder().register(symbolKinds: registeredOnDecoder)
        
        XCTAssertTrue(SymbolGraph.Symbol.KindIdentifier.allCases.contains(registeredOnStaticContext))
        XCTAssertFalse(SymbolGraph.Symbol.KindIdentifier.allCases.contains(registeredOnDecoder))
    }

    func testKindDecoding() throws {
        var schemaData: Data
        var kindJson: String
        
        let jsonDecoder = JSONDecoder()

        kindJson = """
            {"identifier": "swift.func", "displayName": "Function"}
        """
        schemaData = kindJson.data(using: .utf8)!
        let kind = try jsonDecoder.decode(SymbolGraph.Symbol.Kind.self, from: schemaData)
        XCTAssertNotNil(kind)
        XCTAssertEqual(kind.identifier, .func)
        XCTAssertEqual(kind.displayName, "Function")
        
        // Verify that the identifier can parse without the "swift." prefix
        kindJson = """
            "func"
        """
        schemaData = kindJson.data(using: .utf8)!
        let identifier = try jsonDecoder.decode(SymbolGraph.Symbol.KindIdentifier.self, from: schemaData)
        XCTAssertNotNil(identifier)
        XCTAssertEqual(identifier, .func)
    }
    
    func testIdentifierRetrieval() throws {
        var theCase: SymbolGraph.Symbol.KindIdentifier
        
        theCase = .class
        XCTAssertEqual(theCase.identifier, "class")
    }

    func testVariousLanguagePrefixes() throws {
        let identifiers = ["func", "swift.func", "objc.func"]
        let jsonDecoder = JSONDecoder()

        for identifier in identifiers {
            let parsed = SymbolGraph.Symbol.KindIdentifier(identifier: identifier)

            XCTAssertEqual(parsed, .func)

            let kindJson = """
                {"identifier": "\(identifier)", "displayName": "Function"}
            """
            let schemaData = kindJson.data(using: .utf8)!
            let kind = try jsonDecoder.decode(SymbolGraph.Symbol.Kind.self, from: schemaData)
            XCTAssertNotNil(kind)
            XCTAssertEqual(kind.identifier, .func)
            XCTAssertEqual(kind.displayName, "Function")
        }
    }

    /// Make sure that all the cases added to `KindIdentifier` can parse back as themselves
    /// when their `identifier` string is given back to the `.init(identifier:)` initializer.
    func testKindIdentifierRoundtrip() throws {
        for identifier in SymbolGraph.Symbol.KindIdentifier.allCases {
            let parsed = SymbolGraph.Symbol.KindIdentifier(identifier: identifier.identifier)

            XCTAssertEqual(identifier, parsed)
        }
    }
}
