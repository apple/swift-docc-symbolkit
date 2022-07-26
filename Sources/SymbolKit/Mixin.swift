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

// This extension provides coding information for any instance of Mixin. These
// coding infos wrap the encoding and decoding logic for the respective
// instances in a type-erased way. Thus, the concrete instance type of Mixins
// does not need to be known by the encoding/decoding logic in Symbol and
// Relationship.
extension Mixin {
    static var symbolCodingInfo: SymbolMixinCodingInfo {
        let key = SymbolGraph.Symbol.CodingKeys(rawValue: Self.mixinKey)
        return MixinCodingInformation(codingKey: key,
                               encode: { mixin, container in
            try container.encode(mixin as! Self, forKey: key)
        },
                               decode: { container in
            try container.decode(Self.self, forKey: key)
        })
    }
    
    static var relationshipCodingInfo: RelationshipMixinCodingInfo {
        let key = SymbolGraph.Relationship.CodingKeys(rawValue: Self.mixinKey)
        return MixinCodingInformation(codingKey: key,
                               encode: { mixin, container in
            try container.encode(mixin as! Self, forKey: key)
        },
                               decode: { container in
            try container.decode(Self.self, forKey: key)
        })
    }
}

typealias SymbolMixinCodingInfo = MixinCodingInformation<SymbolGraph.Symbol.CodingKeys>

typealias RelationshipMixinCodingInfo = MixinCodingInformation<SymbolGraph.Relationship.CodingKeys>

struct MixinCodingInformation<Key: CodingKey> {
    let codingKey: Key
    let encode: (Mixin, inout KeyedEncodingContainer<Key>) throws -> Void
    let decode: (KeyedDecodingContainer<Key>) throws -> Mixin?
}

extension MixinCodingInformation {
    func with(encodingErrorHandler: @escaping (_ error: Error, _ mixin: Mixin) throws -> Void) -> Self {
        MixinCodingInformation(codingKey: self.codingKey, encode: { mixin, container in
            do {
                try self.encode(mixin, &container)
            } catch {
                try encodingErrorHandler(error, mixin)
            }
        }, decode: self.decode)
    }
    
    func with(decodingErrorHandler: @escaping (_ error: Error) throws -> Mixin?) -> Self {
        MixinCodingInformation(codingKey: self.codingKey, encode: self.encode, decode: { container in
            do {
                return try self.decode(container)
            } catch {
                return try decodingErrorHandler(error)
            }
        })
    }
}
