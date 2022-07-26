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
 to register its type to your encoder/decoder instance using ``SymbolGraph/Relationship/register(mixins:to:)``
 or ``SymbolGraph/Symbol/register(mixins:to:)``, respectively.
 */
public protocol Mixin: Codable {
    /**
     The key under which a mixin's data is filed.

     > Important: With respect to deserialization, this framework assumes `mixinKey`s between instances of `SymbolMixin` are unique.
     */
    static var mixinKey: String { get }
    
    /// Defines the behavior when an error occurs while decoding this type of ``Mixin``.
    ///
    /// Next to logging warnings, the function allows for either re-throwing the error,
    /// skipping the errornous entry, or providing a default value.
    static func onDecodingError(_ error: Error) throws -> Mixin?

    /// Defines the behavior when an error occurs while encoding this type of ``Mixin``.
    ///
    /// You can either re-throw or consume the error.
    static func onEncodingError(_ error: Error, mixin: Mixin) throws
}

public extension Mixin {
    /// By default, ``Mixin``s re-throw errors occurring during decoding.
    static func onDecodingError(_ error: Error) throws -> Mixin? {
        throw error
    }
    
    /// By default, ``Mixin``s re-throw errors occurring during encoding.
    static func onEncodingError(_ error: Error, mixin: Mixin) throws {
        throw error
    }
}

// This extension provides coding keys for any instance of Mixin. These
// coding keys wrap the encoding and decoding logic for the respective
// instances in a type-erased way. Thus, the concrete instance type of Mixins
// does not need to be known by the encoding/decoding logic in Symbol and
// Relationship.
extension Mixin {
    static var symbolCodingKey: SymbolGraph.Symbol.CodingKeys {
        SymbolGraph.Symbol.CodingKeys(rawValue: Self.mixinKey, encoder: { key, mixin, container in
            do {
                try container.encode(mixin as! Self, forKey: key)
            } catch {
                try Self.onEncodingError(error, mixin: mixin)
            }
        }, decoder: { key, container in
            do {
                return try container.decode(Self.self, forKey: key)
            } catch {
                return try Self.onDecodingError(error)
            }
        })
    }
    
    static var relationshipCodingKey: SymbolGraph.Relationship.CodingKeys {
        SymbolGraph.Relationship.CodingKeys(rawValue: Self.mixinKey, encoder: { key, mixin, container in
            do {
                try container.encode(mixin as! Self, forKey: key)
            } catch {
                try Self.onEncodingError(error, mixin: mixin)
            }
        }, decoder: { key, container in
            do {
                return try container.decode(Self.self, forKey: key)
            } catch {
                return try Self.onDecodingError(error)
            }
        })
    }
}
