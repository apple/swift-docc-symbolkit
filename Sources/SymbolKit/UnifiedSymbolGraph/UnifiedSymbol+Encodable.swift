/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation

extension UnifiedSymbolGraph.Symbol: Encodable {
    enum CodingKeys: String, CaseIterable, CodingKey {
        // Base
        case uniqueIdentifier
        case mainGraphSelectors
        case modules
        case kind
        case pathComponents
        case type
        case names
        case docComment
        case accessLevel
        case mixins
    }

    private struct EncodableModule: Encodable {
        var selector: UnifiedSymbolGraph.Selector
        var module: SymbolGraph.Module
    }

    private struct EncodableKind: Encodable {
        var selector: UnifiedSymbolGraph.Selector
        var kind: SymbolGraph.Symbol.Kind
    }

    private struct EncodablePathComponents: Encodable {
        var selector: UnifiedSymbolGraph.Selector
        var pathComponents: [String]
    }

    private struct EncodableNames: Encodable {
        var selector: UnifiedSymbolGraph.Selector
        var names: SymbolGraph.Symbol.Names
    }

    private struct EncodableDocComment: Encodable {
        var selector: UnifiedSymbolGraph.Selector
        var docComment: SymbolGraph.LineList
    }

    private struct EncodableAccessLevel: Encodable {
        var selector: UnifiedSymbolGraph.Selector
        var accessLevel: SymbolGraph.Symbol.AccessControl
    }

    private struct EncodableMixins: Encodable {
        var selector: UnifiedSymbolGraph.Selector
        var mixins: [String: Mixin]

        func encode(to encoder: Encoder) throws {
            // To keep Symbol's flexibility when coding Mixins, we use
            // Symbol's CodingKeys.
            var container = encoder.container(keyedBy: SymbolGraph.Symbol.CodingKeys.self)

            try container.encode(selector, forKey: SymbolGraph.Symbol.CodingKeys(rawValue: "selector"))

            // This is copied from SymbolGraph.Symbol's encoding method
            for (key, mixin) in mixins {
                guard let info = SymbolGraph.Symbol.CodingKeys.mixinCodingInfo[key] ?? encoder.registeredSymbolMixins?[key] else {
                    continue
                }
                
                try info.encode(mixin, &container)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Base

        try container.encode(uniqueIdentifier, forKey: .uniqueIdentifier)
        try container.encode(mainGraphSelectors, forKey: .mainGraphSelectors)
        try container.encodeIfPresent(type, forKey: .type)

        let encodedModules = modules.map({ EncodableModule(selector: $0.key, module: $0.value) })
        if !encodedModules.isEmpty {
            try container.encode(encodedModules, forKey: .modules)
        }

        let encodedKinds = kind.map({ EncodableKind(selector: $0.key, kind: $0.value) })
        if !encodedKinds.isEmpty {
            try container.encode(encodedKinds, forKey: .kind)
        }

        let encodedPathComponents = pathComponents.map({ EncodablePathComponents(selector: $0.key, pathComponents: $0.value) })
        if !encodedPathComponents.isEmpty {
            try container.encode(encodedPathComponents, forKey: .pathComponents)
        }

        let encodedNames = names.map({ EncodableNames(selector: $0.key, names: $0.value) })
        if !encodedNames.isEmpty {
            try container.encode(encodedNames, forKey: .names)
        }

        let encodedDocComments = docComment.map({ EncodableDocComment(selector: $0.key, docComment: $0.value) })
        if !encodedDocComments.isEmpty {
            try container.encode(encodedDocComments, forKey: .docComment)
        }

        let encodedAccessLevels = accessLevel.map({ EncodableAccessLevel(selector: $0.key, accessLevel: $0.value) })
        if !encodedAccessLevels.isEmpty {
            try container.encode(encodedAccessLevels, forKey: .accessLevel)
        }

        let encodedMixins = mixins.map({ EncodableMixins(selector: $0.key, mixins: $0.value) })
        if !encodedMixins.isEmpty {
            try container.encode(encodedMixins, forKey: .mixins)
        }
    }
}
