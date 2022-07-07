/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation

extension SymbolGraph.Relationship {
    /// The kind of relationship.
    public struct Kind: Codable, RawRepresentable, Equatable, Hashable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /**
         A symbol `A` is a member of another symbol `B`.

         For example, a method or field of a class would be
         a member of that class.

         The implied inverse of this relationship is that
         symbol `B` is the owner of a member symbol `A`.
         */
        public static let memberOf = Kind(rawValue: "memberOf")

        /**
         A symbol `A` conforms to an interface/protocol symbol `B`.

         For example, a class `C` that conforms to protocol `P` in Swift would
         use this relationship.

         The implied inverse of this relationship is that
         a symbol `B` that has a conformer `A`.
         */
        public static let conformsTo = Kind(rawValue: "conformsTo")

        /**
         A symbol `A` inherits another symbol `B`.

         For example, a derived class inherits from a base class,
         or a protocol that refines another protocol would use this relationship.

         The implied inverse of this relationship is that
         a symbol `B` is a base of another symbol `A`.
         */
        public static let inheritsFrom = Kind(rawValue: "inheritsFrom")

        /**
         A symbol `A` serves as a default implementation of
         an interface requirement `B`.

         The implied inverse of this relationship is that
         an interface requirement `B` has a default implementation of `A`.
         */
        public static let defaultImplementationOf = Kind(rawValue: "defaultImplementationOf")

        /**
         A symbol `A` overrides another symbol `B`, typically through inheritance.

         The implied inverse of this relationship is that
         a symbol `A` is the base of symbol `B`.
         */
        public static let overrides = Kind(rawValue: "overrides")

        /**
         A symbol `A` is a requirement of interface `B`.

         The implied inverse of this relationship is that
         an interface `B` has a requirement of `A`.
         */
        public static let requirementOf = Kind(rawValue: "requirementOf")

        /**
         A symbol `A` is an optional requirement of interface `B`.

         The implied inverse of this relationship is that
         an interface `B` has an optional requirement of `A`.
         */
        public static let optionalRequirementOf = Kind(rawValue: "optionalRequirementOf")
        
        /**
         A symbol `A` extends a symbol `B` with members or conformances.

         This relationship describes the connection between extension blocks
         (swift.extension symbols) and the type they extend.

         The implied inverse of this relationship is a symbol `B` that is extended
         by an extension block symbol `A`.
         */
        public static let extensionTo = Kind(rawValue: "extensionTo")
    }
}
