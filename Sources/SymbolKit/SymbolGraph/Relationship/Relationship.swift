/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

extension SymbolGraph {
    /**
     A relationship between two `Symbol`s; a directed edge in a graph.
     */
    public struct Relationship: Codable {
        /// The precise identifier of the symbol that has a relationship.
        public var source: String

        /// The precise identifier of the symbol that the `source` is related to.
        public var target: String

        /// The type of relationship that this edge represents.
        public var kind: Kind

        /// A fallback display name for the target if its module's symbol graph
        /// is not available.
        public var targetFallback: String?

        /// Extra information about a relationship that is not necessarily common to all relationships
        ///
        /// - Warning: If you intend to ``encode(to:)`` this relationship, make sure to ``register(_:)``
        /// any added ``Mixin``s that do not appear on relationships in the standard format.
        ///
        /// - Note: You can use the ``subscript(mixin:)`` to automatically ``register(_:)``
        /// the ``Mixin`` types you add.
        public var mixins: [String: Mixin] = [:]
        
        /// Extra information about a relationship that is not necessarily common to all relationships
        ///
        /// - Note: ``Mixin``s added via this subscript will be included when encoding this type.
        public subscript<M: Mixin>(mixin mixin: M.Type = M.self) -> M? {
            get {
                mixins[mixin.mixinKey] as? M
            }
            set {
                mixins[mixin.mixinKey] = newValue
                
                if !CodingKeys.mixinKeys.contains(CodingKeys(rawValue: M.mixinKey)) {
                    CodingKeys.mixinKeys.update(with: M.relationshipCodingKey)
                }
            }
        }
        
        /// Register types conforming to ``Mixin`` so they can be included when encoding or
        /// decoding relationships.
        ///
        /// If ``Relationship`` does not know the concrete type of a ``Mixin``, it cannot encode
        /// or decode that type and thus skipps such entries. Note that ``Mixin``s that occur on relationships
        /// in the default symbol graph format do not have to be registered!
        public static func register(_ mixinTypes: Mixin.Type...) {
            CodingKeys.mixinKeys.formUnion(mixinTypes.map { type in type.relationshipCodingKey })
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            source = try container.decode(String.self, forKey: .source)
            target = try container.decode(String.self, forKey: .target)
            kind = try container.decode(Kind.self, forKey: .kind)
            targetFallback = try container.decodeIfPresent(String.self, forKey: .targetFallback)
            
            let mixinKeys = Set(container.allKeys).intersection(CodingKeys.mixinKeys)
            
            for key in mixinKeys {
                guard let decode = key.decoder else {
                    continue
                }
                
                let decoded = try decode(key, container)
                
                mixins[key.stringValue] = decoded
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            // Base

            try container.encode(kind, forKey: .kind)
            try container.encode(source, forKey: .source)
            try container.encode(target, forKey: .target)
            try container.encode(targetFallback, forKey: .targetFallback)

            // Mixins

            for (key, mixin) in mixins {
                guard let key = CodingKeys(stringValue: key) else {
                    continue
                }
                
                guard let encode = key.encoder else {
                    continue
                }
                
                try encode(key, mixin, &container)
            }
        }

        public init(source: String, target: String, kind: Kind, targetFallback: String?) {
            self.source = source
            self.target = target
            self.kind = kind
            self.targetFallback = targetFallback
        }
    }
}

extension SymbolGraph.Relationship: Hashable, Equatable {

    /// A custom hashing for the relationship.
    /// > Important: If there are new relationship mixins they need to be added to the hasher in this function.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(source)
        hasher.combine(target)
        hasher.combine(kind.rawValue)
        hasher.combine(targetFallback)
        hasher.combine(mixins[SymbolGraph.Relationship.Swift.GenericConstraints.mixinKey] as? Swift.GenericConstraints)
        hasher.combine(mixins[SymbolGraph.Relationship.SourceOrigin.mixinKey] as? SourceOrigin)
    }

    /// A custom equality implmentation for a relationship.
    /// > Important: If there are new relationship mixins they need to be added to the equality function.
    public static func == (lhs: SymbolGraph.Relationship, rhs: SymbolGraph.Relationship) -> Bool {
        return lhs.source == rhs.source
            && lhs.target == rhs.target
            && lhs.kind == rhs.kind
            && lhs.targetFallback == rhs.targetFallback
            && lhs.mixins[SymbolGraph.Relationship.Swift.GenericConstraints.mixinKey] as? Swift.GenericConstraints
                == rhs.mixins[SymbolGraph.Relationship.Swift.GenericConstraints.mixinKey] as? Swift.GenericConstraints
            && lhs.mixins[SymbolGraph.Relationship.SourceOrigin.mixinKey] as? SourceOrigin
                == rhs.mixins[SymbolGraph.Relationship.SourceOrigin.mixinKey] as? SourceOrigin
    }
}

extension SymbolGraph.Relationship {
    struct CodingKeys: CodingKey, Hashable {
        let stringValue: String
        let encoder: ((Self, Mixin, inout KeyedEncodingContainer<CodingKeys>) throws -> ())?
        let decoder: ((Self, KeyedDecodingContainer<CodingKeys>) throws -> Mixin?)?
        
        
        init?(stringValue: String) {
            // When a decoder initializes such coding key from a
            // string, this implementation tries to find an equivalent
            // coding key in the static set. If such key is found, this
            // key is used as it contains the required logic for decoding.
            let candidate = CodingKeys(rawValue: stringValue)
            if let index = Self.baseKeys.firstIndex(of: candidate) {
                self = Self.baseKeys[index]
            } else if let index = Self.mixinKeys.firstIndex(of: candidate) {
                self = Self.mixinKeys[index]
            } else {
                return nil
            }
        }
        
        init(rawValue: String,
             encoder: ((Self, Mixin, inout KeyedEncodingContainer<CodingKeys>) throws -> ())? = nil,
             decoder: ((Self, KeyedDecodingContainer<CodingKeys>) throws -> Mixin?)? = nil) {
            self.stringValue = rawValue
            self.encoder = encoder
            self.decoder = decoder
        }
        
        // Base
        static let source = CodingKeys(rawValue: "source")
        static let target = CodingKeys(rawValue: "target")
        static let kind = CodingKeys(rawValue: "kind")
        static let targetFallback = CodingKeys(rawValue: "targetFallback")
        
        static let baseKeys: Set<CodingKeys> = [.source,
                                                .target,
                                                .kind,
                                                .targetFallback]
        

        // Mixins
        static let swiftConstraints = Swift.GenericConstraints.relationshipCodingKey
        static let sourceOrigin = SourceOrigin.relationshipCodingKey
        
        static var mixinKeys: Set<CodingKeys> = [
            .swiftConstraints,
            .sourceOrigin,
        ]
        
        static func == (lhs: SymbolGraph.Relationship.CodingKeys, rhs: SymbolGraph.Relationship.CodingKeys) -> Bool {
            lhs.stringValue == rhs.stringValue
        }
        
        func hash(into hasher: inout Hasher) {
            stringValue.hash(into: &hasher)
        }
        
        var intValue: Int? { nil }
        
        init?(intValue: Int) {
            nil
        }
    }
}
