/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

extension SymbolGraph {
    /**
     A symbol from a module.

     A `Symbol` corresponds to some named declaration in a module.
     For example, a class is a `Symbol` in the graph.

     A `Symbol` should never contain another `Symbol` as a field or part of a field.
     If a symbol is related to another symbol, it should be formalized
     as a `Relationship` in an `Edge` if possible (it usually is).

     Symbols may have information that is specific to its kind, but all symbols
     must contain at least the following information in the `Symbol` interface.

     In addition, various attributes of the symbol should be mixed in with
     symbol *mix-ins*, some of which are defined below.
     The consumer of a symbol graph should be able to dynamically handle or ignore
     additional attributes in a `Symbol`.
     */
    public struct Symbol: Codable {
        /// The unique identifier for the symbol.
        public var identifier: Identifier

        /// The kind of symbol.
        public var kind: Kind

        /**
         A short convenience path that uniquely identifies a symbol when there are no ambiguities using only URL-compatible characters. Do not include the module name here.

         For example, in a Swift module `MyModule`, there might exist a function `bar` in `struct Foo`.
         The `simpleComponents` for `bar` would be `["Foo", "bar"]`, corresponding to `Foo.bar`.

         > Note: When writing relative links, an author may choose to remove leading components, so disambiguating path components should only be appended to the end, not prepended to the beginning.
         */
        public var pathComponents: [String]

        /// If the static type of a symbol is known, the precise identifier of
        /// the symbol that declares the type.
        public var type: String?

        /// The context-specific names of a symbol.
        public var names: Names

        /// The in-source documentation comment attached to a symbol.
        public var docComment: LineList?

        /// If the symbol has a documentation comment, whether the documentation comment is from
        /// the same module as the symbol or not.
        ///
        /// An inherited documentation comment is from the same module when the symbol that the documentation is inherited from is in the same module as this symbol.
        @available(*, deprecated, message: "Use 'isDocCommentFromSameModule(symbolModuleName:)' instead.")
        public var isDocCommentFromSameModule: Bool? {
            _isDocCommentFromSameModule
        }
        // To avoid deprecation warnings in SymbolKit test until the deprecated property is removed.
        internal var _isDocCommentFromSameModule: Bool? {
            guard let docComment = docComment, !docComment.lines.isEmpty else {
                return nil
            }

            // As a current implementation detail, documentation comments from within the current module has range information but
            // documentation comments that are inherited from other modules don't have any range information.
            //
            // This isn't always correct and is only used as a fallback logic for symbol information before the source module was
            // included in the symbol graph file.
            return docComment.lines.contains(where: { $0.range != nil })
        }
        
        /// If the symbol has a documentation comment, checks whether the documentation comment is from the same module as the symbol.
        ///
        /// A documentation comment is from the same module as the symbol when the source of the documentation comment is the symbol itself or another symbol in the same module.
        ///
        /// - Parameter symbolModuleName: The name of the module where the symbol is defined.
        /// - Returns: `true`if the source of the documentation comment is from the same module as this symbol.
        public func isDocCommentFromSameModule(symbolModuleName: String) -> Bool? {
            guard let docComment = docComment, !docComment.lines.isEmpty else {
                return nil
            }
            
            if let moduleName = docComment.moduleName {
                // If the new source module information is available, rely on that.
                return moduleName == symbolModuleName
            } else {
                // Otherwise, fallback to the previous implementation.
                return _isDocCommentFromSameModule
            }
        }

        /// The access level of the symbol.
        public var accessLevel: AccessControl

        /// Information about a symbol that is not necessarily common to all symbols.
        ///
        /// - Warning: If you intend to ``encode(to:)`` this symbol, make sure to ``register(_:)``
        /// any added ``Mixin``s that do not appear on symbols in the standard format.
        ///
        /// - Note: You can use the ``subscript(mixin:)`` to automatically ``register(_:)``
        /// the ``Mixin`` types you add.
        public var mixins: [String: Mixin] = [:]
        
        /// Information about a symbol that is not necessarily common to all symbols.
        ///
        /// - Note: ``Mixin``s added via this subscript will be included when encoding this type.
        public subscript<M: Mixin>(mixin mixin: M.Type = M.self) -> M? {
            get {
                mixins[mixin.mixinKey] as? M
            }
            set {
                mixins[mixin.mixinKey] = newValue
                
                if !CodingKeys.mixinKeys.contains(CodingKeys(rawValue: M.mixinKey)) {
                    CodingKeys.mixinKeys.update(with: M.symbolCodingKey)
                }
            }
        }
        
        /// Register types conforming to ``Mixin`` so they can be included when encoding or
        /// decoding symbols.
        ///
        /// If ``Symbol`` does not know the concrete type of a ``Mixin``, it cannot encode
        /// or decode that type and thus skipps such entries. Note that ``Mixin``s that occur on symbols
        /// in the default symbol graph format do not have to be registered!
        public static func register(_ mixinTypes: Mixin.Type...) {
            CodingKeys.mixinKeys.formUnion(mixinTypes.map { type in type.symbolCodingKey })
        }
        
        
        public init(identifier: Identifier, names: Names, pathComponents: [String], docComment: LineList?, accessLevel: AccessControl, kind: Kind, mixins: [String: Mixin]) {
            self.identifier = identifier
            self.names = names
            self.pathComponents = pathComponents
            self.docComment = docComment
            self.accessLevel = accessLevel
            self.kind = kind
            self.mixins = mixins
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            identifier = try container.decode(Identifier.self, forKey: .identifier)
            kind = try container.decode(Kind.self, forKey: .kind)
            pathComponents = try container.decode([String].self, forKey: .pathComponents)
            type = try container.decodeIfPresent(String.self, forKey: .type)
            names = try container.decode(Names.self, forKey: .names)
            docComment = try container.decodeIfPresent(LineList.self, forKey: .docComment)
            accessLevel = try container.decode(AccessControl.self, forKey: .accessLevel)
            
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

            try container.encode(identifier, forKey: .identifier)
            try container.encode(kind, forKey: .kind)
            try container.encode(pathComponents, forKey: .pathComponents)
            try container.encode(names, forKey: .names)
            try container.encodeIfPresent(docComment, forKey: .docComment)
            try container.encode(accessLevel, forKey: .accessLevel)

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

        /**
         The absolute path from the module or framework to the symbol itself.
         */
        public var absolutePath: String {
            return pathComponents.joined(separator: "/")
        }
    }
}

extension SymbolGraph.Symbol {
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
        static let identifier = CodingKeys(rawValue: "identifier")
        static let kind = CodingKeys(rawValue: "kind")
        static let pathComponents = CodingKeys(rawValue: "pathComponents")
        static let type = CodingKeys(rawValue: "type")
        static let names = CodingKeys(rawValue: "names")
        static let docComment = CodingKeys(rawValue: "docComment")
        static let accessLevel = CodingKeys(rawValue: "accessLevel")
        
        static let baseKeys: Set<CodingKeys> = [.identifier,
                                                .kind,
                                                .pathComponents,
                                                .type,
                                                .names,
                                                .docComment,
                                                .accessLevel]
        

        // Mixins
        static let availability = Availability.symbolCodingKey
        static let declarationFragments = DeclarationFragments.symbolCodingKey
        static let isReadOnly = Mutability.symbolCodingKey
        static let swiftExtension = Swift.Extension.symbolCodingKey
        static let swiftGenerics = Swift.Generics.symbolCodingKey
        static let location = Location.symbolCodingKey
        static let functionSignature = FunctionSignature.symbolCodingKey
        static let spi = SPI.symbolCodingKey
        static let snippet = Snippet.symbolCodingKey
        
        static var mixinKeys: Set<CodingKeys> = [
            .availability,
            .declarationFragments,
            .isReadOnly,
            .swiftExtension,
            .swiftGenerics,
            .location,
            .functionSignature,
            .spi,
            .snippet,
        ]
        
        static func == (lhs: SymbolGraph.Symbol.CodingKeys, rhs: SymbolGraph.Symbol.CodingKeys) -> Bool {
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
