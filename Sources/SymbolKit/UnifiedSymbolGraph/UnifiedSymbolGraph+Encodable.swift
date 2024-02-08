/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation

extension UnifiedSymbolGraph: Encodable {
    enum CodingKeys: String, CaseIterable, CodingKey {
        case moduleName
        case moduleData
        case metadata
        case symbols
        case relationshipsByLanguage
        case orphanRelationships
    }

    private struct EncodableModuleData: Encodable {
        var url: URL
        var moduleData: SymbolGraph.Module
    }

    private struct EncodableMetadata: Encodable {
        var url: URL
        var metadata: SymbolGraph.Metadata
    }

    private struct EncodableRelationships: Encodable {
        var selector: Selector
        var relationships: [SymbolGraph.Relationship]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(moduleName, forKey: .moduleName)

        let encodableModuleData = moduleData.map({ EncodableModuleData(url: $0.key, moduleData: $0.value) })
        try container.encode(encodableModuleData, forKey: .moduleData)

        let encodableMetadata = metadata.map({ EncodableMetadata(url: $0.key, metadata: $0.value) })
        try container.encode(encodableMetadata, forKey: .metadata)

        try container.encode(Array(symbols.values), forKey: .symbols)

        let encodableRelationships = relationshipsByLanguage.map({ EncodableRelationships(selector: $0.key, relationships: $0.value) })
        try container.encode(encodableRelationships, forKey: .relationshipsByLanguage)

        try container.encode(orphanRelationships, forKey: .orphanRelationships)
    }
}
