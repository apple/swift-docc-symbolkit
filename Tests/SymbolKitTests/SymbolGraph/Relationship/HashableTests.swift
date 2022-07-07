/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation
import XCTest
import SymbolKit

class HashableTests: XCTestCase {
    /// Test hasing works as expected if Mixins conform to Hashable
    func testHashingWithHashableMixins() throws {
        var a1 = SymbolGraph.Relationship(source: "a.source", target: "a.target", kind: .conformsTo, targetFallback: nil)
        a1.mixins[SymbolGraph.Relationship.SourceOrigin.mixinKey] = SymbolGraph.Relationship.SourceOrigin(identifier: "a.1.origin", displayName: "a.1.origin")
        
        var a2 = SymbolGraph.Relationship(source: "a.source", target: "a.target", kind: .conformsTo, targetFallback: nil)
        a2.mixins[SymbolGraph.Relationship.SourceOrigin.mixinKey] = SymbolGraph.Relationship.SourceOrigin(identifier: "a.2.origin", displayName: "a.2.origin")
        
        XCTAssertEqual(Set([a1, a2]).count, 2)
    }
    
    /// Check that Mixins that do not implement Hashable are ignored, so that
    /// they don't render the Hashable implementation of Relationship useless.
    func testHashingWithNonHashableMixins() throws {
        var a1 = SymbolGraph.Relationship(source: "a.source", target: "a.target", kind: .conformsTo, targetFallback: nil)
        a1.mixins[NotHashableMixin<String>.mixinKey] = NotHashableMixin(value: "a.1.value")
        
        var a2 = SymbolGraph.Relationship(source: "a.source", target: "a.target", kind: .conformsTo, targetFallback: nil)
        a2.mixins[NotHashableMixin<String>.mixinKey] = NotHashableMixin(value: "a.2.value")
        
        XCTAssertEqual(Set([a1, a2]).count, 1)
    }
    
    /// Check that Mixins that do not implement Hashable of different type
    /// are considered unequal.
    func testHashingWithDifferentTypeNonHashableMixins() throws {
        var a1 = SymbolGraph.Relationship(source: "a.source", target: "a.target", kind: .conformsTo, targetFallback: nil)
        a1.mixins[NotHashableMixin<String>.mixinKey] = NotHashableMixin(value: "a.1.value")
        
        var a2 = SymbolGraph.Relationship(source: "a.source", target: "a.target", kind: .conformsTo, targetFallback: nil)
        a2.mixins[NotHashableMixin<Int>.mixinKey] = NotHashableMixin(value: 2)
        
        XCTAssertEqual(Set([a1, a2]).count, 2)
    }
}

private struct NotHashableMixin<T>: Mixin where T: Codable {
    static var mixinKey: String { "nothashable" }
    
    let value: T
}
