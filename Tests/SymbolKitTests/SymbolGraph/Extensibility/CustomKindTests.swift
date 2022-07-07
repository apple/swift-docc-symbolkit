/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation
import SymbolKit
import XCTest

extension SymbolGraph.Symbol.KindIdentifier {
    static let custom = Self(rawValue: "custom")
}

extension SymbolGraph.Relationship.Kind {
    static let custom = Self(rawValue: "custom")
}

class CustomKindTests: XCTestCase {
    /// Check that language prefix parsing works as usual for custom symbol kinds.
    func testLanguagePrefixParsing() throws {
        SymbolGraph.Symbol.KindIdentifier.register(.custom)
        XCTAssertEqual(SymbolGraph.Symbol.KindIdentifier.custom, .init(identifier: "swift.custom"))
    }
}
