/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation
import SymbolKit
import XCTest

/// Tests symbol graph creation as would be done by clients of SymbolKit.
///
/// `SymbolKit` is intentionally imported in this file without `@testable` to verify
/// that the public API is sufficient for clients.
class SymbolGraphCreationTests: XCTestCase {
    func testCreateAndEncodeSymbolGraph() throws {
        let symbolGraph = SymbolGraph(
            metadata: .init(
                formatVersion: .init(0, 5, 0),
                generator: "org.swift.SymbolKitTests"
            ),
            module: .init(
                name: "Games",
                platform: .init(
                    architecture: nil,
                    vendor: nil,
                    operatingSystem: .init(
                        name: "MyOS",
                        minimumVersion: .init(1, 2, 3)
                    ),
                    environment: nil
                )
            ),
            symbols: [
                SymbolGraph.Symbol(
                    identifier: .init(
                        precise: "c:objc(cs)PlayingCard",
                        interfaceLanguage: "swift"
                    ),
                    names: .init(
                        title: "PlayingCard",
                        navigator: [
                            .init(
                                kind: .identifier,
                                spelling: "PlayingCard",
                                preciseIdentifier: nil
                            ),
                        ],
                        subHeading: [
                            .init(
                                kind: .keyword,
                                spelling: "class",
                                preciseIdentifier: nil
                            ),
                            .init(
                                kind: .text,
                                spelling: " ",
                                preciseIdentifier: nil
                            ),
                            .init(
                                kind: .identifier,
                                spelling: "PlayingCard",
                                preciseIdentifier: nil
                            )
                        ],
                        prose: "Playing Card"
                    ),
                    pathComponents: ["PlayingCard"],
                    docComment: .init(
                        [
                            .init(
                                text: "test",
                                range: .init(
                                    start: .init(
                                        line: 0,
                                        character: 0
                                    ),
                                    end: .init(
                                        line: 0,
                                        character: 5
                                    )
                                )
                            )
                        ]
                    ),
                    accessLevel: .init(rawValue: "open"),
                    kind: .init(
                        parsedIdentifier: .class,
                        displayName: "Class"
                    ),
                    mixins: [
                        SymbolGraph.Symbol.DeclarationFragments.mixinKey : SymbolGraph.Symbol.DeclarationFragments(
                            declarationFragments: [
                                .init(
                                    kind: .keyword,
                                    spelling: "class",
                                    preciseIdentifier: nil
                                ),
                                .init(
                                    kind: .text,
                                    spelling: " ",
                                    preciseIdentifier: nil
                                ),
                                .init(
                                    kind: .identifier,
                                    spelling: "PlayingCard",
                                    preciseIdentifier: nil
                                )
                            ]
                        ),
                        SymbolGraph.Symbol.Location.mixinKey : SymbolGraph.Symbol.Location(
                            uri: "/path/to/PlayingCard.swift",
                            position: .init(line: 0, character: 0)
                        ),
                    ]
                )
            ],
            relationships: [
                .init(
                    source: "c:objc(cs)PlayingCard",
                    target: "c:objc(cs)Deck",
                    kind: .memberOf,
                    targetFallback: nil
                )
            ]
        )
        
        let sortedJSONEncoder = JSONEncoder()
        sortedJSONEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let encodedSymbolGraph = try sortedJSONEncoder.encode(symbolGraph)
        let encodedSymbolGraphString = String(data: encodedSymbolGraph, encoding: .utf8)
        
        let decodedSymbolGraph = try JSONDecoder().decode(SymbolGraph.self, from: encodedSymbolGraph)
        
        // The SymbolGraph model is not `Equatable` so we re-encode to a string to compare the
        // equality.
        let reEncodedSymbolGraph = try sortedJSONEncoder.encode(decodedSymbolGraph)
        let reEncodedSymbolGraphString = String(data: reEncodedSymbolGraph, encoding: .utf8)
        
        XCTAssertEqual(
            encodedSymbolGraphString,
            reEncodedSymbolGraphString,
            "Round-trip SymbolGraph encoding failed."
        )
    }
}
