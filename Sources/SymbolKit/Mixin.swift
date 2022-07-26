/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation

/**
 A protocol that allows extracted symbols to have extra data
 aside from the base ``SymbolGraph/Symbol``.
 
 - Note: If you intend to encode/decode a custom ``Mixin`` as part of a relationship or symbol, make sure
 to register its type to your encoder/decoder instance using
 ``SymbolGraph/Relationship/register(mixins:to:onEncodingError:onDecodingError:)``
 or ``SymbolGraph/Symbol/register(mixins:to:onEncodingError:onDecodingError:)``, respectively.
 */
public protocol Mixin: Codable {
    /**
     The key under which a mixin's data is filed.

     > Important: With respect to deserialization, this framework assumes `mixinKey`s between instances of `SymbolMixin` are unique.
     */
    static var mixinKey: String { get }
}

// This extension provides coding keys for any instance of Mixin. These
// coding keys wrap the encoding and decoding logic for the respective
// instances in a type-erased way. Thus, the concrete instance type of Mixins
// does not need to be known by the encoding/decoding logic in Symbol and
// Relationship.
extension Mixin {
    static var symbolCodingKey: SymbolGraph.Symbol.CodingKeys {
        SymbolGraph.Symbol.CodingKeys(rawValue: Self.mixinKey, encoder: { key, mixin, container in
            try container.encode(mixin as! Self, forKey: key)
        }, decoder: { key, container in
            try container.decode(Self.self, forKey: key)
        })
    }
    
    static var relationshipCodingKey: SymbolGraph.Relationship.CodingKeys {
        SymbolGraph.Relationship.CodingKeys(rawValue: Self.mixinKey, encoder: { key, mixin, container in
            try container.encode(mixin as! Self, forKey: key)
        }, decoder: { key, container in
            try container.decode(Self.self, forKey: key)
        })
    }
}
