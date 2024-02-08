/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation

/// A combined ``SymbolGraph`` from multiple languages' views of the same module.
public class UnifiedSymbolGraph {

    /// The module that these combined symbol graphs represent.
    public var moduleName: String

    /// The decoded metadata about the module being represented, indexed by the file path of the symbol graph it was decoded from.
    ///
    /// Some module symbol graphs contain different metadata (e.g. platform it was rendered for, "bystander" modules, etc), and this allows users of unified graph data to load individual graphs' module data.
    public var moduleData: [URL: SymbolGraph.Module]

    /// Metadata about the individual symbol graphs that were combined together, indexed by the file path of each input symbol graph.
    public var metadata: [URL: SymbolGraph.Metadata]

    /// The symbols in the module, indexed by precise identifier.
    public var symbols: [String: UnifiedSymbolGraph.Symbol]

    /// The relationships between symbols.
    @available(*, deprecated, message: "Use relationshipsByLanguage and orphanRelationships instead")
    public var relationships: [SymbolGraph.Relationship] {
        var allRelations = mergeRelationships(Array(relationshipsByLanguage.values.joined()))
        allRelations.append(contentsOf: self.orphanRelationships)
        return allRelations
    }

    /// The relationships between symbols, separated by the language's view those relationships are
    /// relevant in.
    public var relationshipsByLanguage: [Selector: [SymbolGraph.Relationship]]

    /// A list of relationships between symbols, for which neither the source nor target were able
    /// to be matched with an appropriate symbol in the collected graphs.
    public var orphanRelationships: [SymbolGraph.Relationship]

    public init?(fromSingleGraph graph: SymbolGraph, at url: URL) {
        let (_, isMainGraph) = GraphCollector.moduleNameFor(graph, at: url)

        self.moduleName = graph.module.name
        self.moduleData = [url: graph.module]
        self.metadata = [url: graph.metadata]
        self.symbols = graph.symbols.mapValues { UnifiedSymbolGraph.Symbol(fromSingleSymbol: $0, module: graph.module, isMainGraph: isMainGraph) }
        self.relationshipsByLanguage = [:]
        self.orphanRelationships = []
        loadRelationships(fromGraph: graph)
    }
}

extension UnifiedSymbolGraph {
    func loadRelationships(fromGraph graph: SymbolGraph) {
        var newRelations: [Selector: [SymbolGraph.Relationship]] = [:]

        for rel in graph.relationships {
            // associate each relationship with a selector based on the symbol(s) it references
            let selectors: [Selector]
            if let sourceSym = graph.symbols[rel.source] {
                selectors = [Selector(interfaceLanguage: sourceSym.identifier.interfaceLanguage, platform: graph.module.platform.name)]
            } else if let targetSym = graph.symbols[rel.target] {
                selectors = [Selector(interfaceLanguage: targetSym.identifier.interfaceLanguage, platform: graph.module.platform.name)]
            } else if let unifiedSourceSym = self.symbols[rel.source] {
                selectors = unifiedSourceSym.mainGraphSelectors
            } else if let unifiedTargetSym = self.symbols[rel.target] {
                selectors = unifiedTargetSym.mainGraphSelectors
            } else {
                // If we can't find the appropriate selector(s) to use, consider the relationship an
                // orphan and save it for later.
                self.orphanRelationships.append(rel)
                continue
            }

            for selector in selectors {
                if !newRelations.keys.contains(selector) {
                    newRelations[selector] = []
                }

                newRelations[selector]!.append(rel)
            }
        }

        for (key: selector, value: relations) in newRelations {
            self.relationshipsByLanguage[selector] = mergeRelationships(self.relationshipsByLanguage[selector, default: []], relations)
        }
    }

    /// Merge the given lists of ``SymbolGraph/Relationship``s.
    ///
    /// This function will deduplicate relationships based on their source, target, and kind. If it sees a duplicate, it will keep the first one it sees.
    func mergeRelationships(_ relationsList: [SymbolGraph.Relationship]...)
    -> [SymbolGraph.Relationship] {
        struct RelationKey: Hashable {
            let source: String
            let target: String
            let kind: SymbolGraph.Relationship.Kind

            init(fromRelation relationship: SymbolGraph.Relationship) {
                self.source = relationship.source
                self.target = relationship.target
                self.kind = relationship.kind
            }

            static func makePair(fromRelation relationship: SymbolGraph.Relationship) -> (RelationKey, SymbolGraph.Relationship) {
                return (RelationKey(fromRelation: relationship), relationship)
            }
        }

        let allRelations = relationsList.joined()

        // deduplicate the combined relationships array by source/target/kind
        // FIXME: Actually merge relationships if they have different mixins (rdar://84267943)
        let map = [:].merging(allRelations.map({ RelationKey.makePair(fromRelation: $0) }), uniquingKeysWith: { r1, r2 in r1 })

        return Array(map.values)
    }

    /// Scans over ``orphanRelationships`` and sorts any whose source/target symbols were loaded
    /// after the relationship was.
    ///
    /// Since relationships are added to ``relationshipsByLanguage`` based on what symbols are
    /// available when the relationship is being loaded, a relationship can be considered an
    /// "orphan" even when it's not, if the symbol graphs are loaded in a certain order. This
    /// method was added to ensure that these relationships can be properly assigned a language
    /// even if the symbol information isn't in the same symbol graph.
    internal func collectOrphans() {
        var newRelations: [Selector: [SymbolGraph.Relationship]] = [:]
        var remainingOrphans: [SymbolGraph.Relationship] = []
        for rel in self.orphanRelationships {
            let selectors: [Selector]
            if let unifiedSourceSym = self.symbols[rel.source] {
                selectors = unifiedSourceSym.mainGraphSelectors
            } else if let unifiedSourceSym = self.symbols[rel.target] {
                selectors = unifiedSourceSym.mainGraphSelectors
            } else {
                remainingOrphans.append(rel)
                continue
            }

            for selector in selectors {
                if !newRelations.keys.contains(selector) {
                    newRelations[selector] = []
                }

                newRelations[selector]!.append(rel)
            }
        }

        for (key: selector, value: relations) in newRelations {
            self.relationshipsByLanguage[selector] = mergeRelationships(self.relationshipsByLanguage[selector, default: []], relations)
        }

        self.orphanRelationships = remainingOrphans
    }

    /// Merge the given symbol graph with this one.
    public func mergeGraph(graph: SymbolGraph, at url: URL) {
        let (_, isMainGraph) = GraphCollector.moduleNameFor(graph, at: url)

        self.metadata[url] = graph.metadata
        self.moduleData[url] = graph.module

        for (key: precise, value: sym) in graph.symbols {
            if let existingSymbol = self.symbols[precise] {
                existingSymbol.mergeSymbol(symbol: sym, module: graph.module, isMainGraph: isMainGraph)
            } else {
                self.symbols[precise] = Symbol(fromSingleSymbol: sym, module: graph.module, isMainGraph: isMainGraph)
            }
        }

        loadRelationships(fromGraph: graph)
    }
}

extension UnifiedSymbolGraph {
    /// A combination of interface language and list of platforms that allows a symbol to be distinguished from another when unifying symbol graphs.
    public struct Selector: Equatable, Hashable, Encodable {
        /// The interface language used for the symbol.
        public let interfaceLanguage: String

        /// The platform that the symbol was built for.
        ///
        /// If the symbol graph that the symbol was sourced from does not contain a `module.platform.operatingSystem`, this will be `nil`.
        public let platform: String?

        public init(interfaceLanguage: String, platform: String?) {
            self.interfaceLanguage = interfaceLanguage
            self.platform = platform
        }

        /// Creates a ``UnifiedSymbolGraph/Selector`` for the given symbol graph's language and platform.
        ///
        /// If `graph` has no symbols, this will return `nil`.
        public init?(forSymbolGraph graph: SymbolGraph) {
            guard let lang = graph.symbols.first?.value.identifier.interfaceLanguage else { return nil }

            self.interfaceLanguage = lang
            self.platform = graph.module.platform.name
        }
    }
}
