/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation

/// An accumulator for incrementally merging ``SymbolGraph``s into ``UnifiedSymbolGraph``s.
public class GraphCollector {
    /// An indicator of whether a loaded symbol graph was a "primary" symbol graph or one that contained
    /// extensions from a different module.
    public enum GraphKind {
        case primary(URL)
        case `extension`(URL)
    }

    /// The list of merged symbol graphs, indexed by module name.
    var unifiedGraphs: [String: UnifiedSymbolGraph] = [:]

    /// The list of files that contributed to each merged symbol graph, indexed by module name.
    var graphSources: [String: [GraphKind]] = [:]

    var extensionGraphs: [URL: SymbolGraph] = [:]
    
    private let extensionGraphAssociationStrategy: ExtensionGraphAssociation

    /// Initialize a new collector for merging ``SymbolGraph``s into ``UnifiedSymbolGraph``s.
    ///
    /// - Parameter extensionGraphAssociationStrategy: Optionally specifiy how extension graphs are to be merged.
    public init(extensionGraphAssociationStrategy: ExtensionGraphAssociation = .extendedGraph) {
        self.unifiedGraphs = [:]
        self.graphSources = [:]
        self.extensionGraphs = [:]
        self.extensionGraphAssociationStrategy = extensionGraphAssociationStrategy
    }
}

extension GraphCollector {
    /// Describes which graph an extension graph (named `ExtendingModule@ExtendedModule.symbols.json`)
    /// is merged with.
    public enum ExtensionGraphAssociation {
        /// Merge with the extending module
        case extendingGraph
        /// Merge with the extended module
        case extendedGraph
    }
}

extension GraphCollector {
    /// Merges the given ``SymbolGraph`` into the set of unified symbol graphs.
    ///
    /// - Parameters:
    ///   - inputGraph: The symbol graph to merge in.
    ///   - url: The file name where the given symbol graph is located. Used to determine whether a symbol graph
    ///     contains primary symbols or extensions.
    public func mergeSymbolGraph(_ inputGraph: SymbolGraph, at url: URL, forceLoading: Bool = false) {
        let (extendedModuleName, isMainSymbolGraph) = Self.moduleNameFor(inputGraph, at: url)

        let moduleName = extensionGraphAssociationStrategy == .extendedGraph ? extendedModuleName : inputGraph.module.name

        if !isMainSymbolGraph && !forceLoading {
            self.extensionGraphs[url] = inputGraph
            return
        }

        if let existingGraph = self.unifiedGraphs[moduleName] {
            existingGraph.mergeGraph(graph: inputGraph, at: url)
        } else {
            self.unifiedGraphs[moduleName] = UnifiedSymbolGraph(fromSingleGraph: inputGraph, at: url)
        }

        let graphURL: GraphKind
        if isMainSymbolGraph {
            graphURL = .primary(url)
        } else {
            graphURL = .`extension`(url)
        }

        if var existingSources = self.graphSources[moduleName] {
            existingSources.append(graphURL)
        } else {
            self.graphSources[moduleName] = [graphURL]
        }
    }

    public func finishLoading() -> (unifiedGraphs: [String: UnifiedSymbolGraph], graphSources: [String: [GraphKind]]) {
        for (url, graph) in self.extensionGraphs {
            self.mergeSymbolGraph(graph, at: url, forceLoading: true)
        }

        for (_, graph) in self.unifiedGraphs {
            graph.collectOrphans()
        }

        return (self.unifiedGraphs, self.graphSources)
    }

    /// Determines the module name for the given symbol graph.
    ///
    /// For Swift, symbol graphs are separated based on whether symbols are extending other symbols in other modules.
    /// Symbols declared in the module itself are saved in a symbol graph file named `ModuleName.symbols.json`,
    /// whereas symbols that extend a different module are saved in a separate file named
    /// `ModuleName@OtherModule.symbols.json`. The latter symbol graph file still declares its module
    /// as `ModuleName`, so this function allows consumers of symbol graphs to determine which module to load
    /// symbols under.
    ///
    /// - Parameters:
    ///   - graph: The symbol graph being checked.
    ///   - url: The file name where the symbol graph is located.
    /// - Returns: The name of the module described by `graph`, and whether the symbol graph is a "primary" symbol graph.
    public static func moduleNameFor(_ graph: SymbolGraph, at url: URL) -> (String, Bool) {
        let isMainSymbolGraph = !url.lastPathComponent.contains("@")

        let moduleName: String
        if isMainSymbolGraph {
            // For main symbol graphs, get the module name from the symbol graph's data
            moduleName = graph.module.name
        } else {
            // For extension symbol graphs, derive the extended module's name from the file name.
            //
            // The per-symbol `extendedModule` value is the same as the main module for most symbols, so it's not a good way to find the name
            // of the module that was extended (rdar://63200368).
            let fileName = url.lastPathComponent.components(separatedBy: ".symbols.json")[0]

            let fileNameComponents = fileName.components(separatedBy: "@")
            if fileNameComponents.count > 2 {
                // For a while, cross-import overlay symbol graphs had more than two components:
                // "Framework1@Framework2@_Framework1_Framework2.symbols.json"
                moduleName = fileNameComponents[0]
            } else {
                moduleName = fileName.split(separator: "@", maxSplits: 1).last.map({ String($0) })!
            }
        }
        return (moduleName, isMainSymbolGraph)
    }
}
