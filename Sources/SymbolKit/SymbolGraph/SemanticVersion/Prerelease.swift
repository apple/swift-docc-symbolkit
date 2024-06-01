/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

extension SymbolGraph.SemanticVersion {
    /// A storage for pre-release identifiers.
    internal struct Prerelease {
        /// The identifiers.
        internal let identifiers: [Identifier]
        /// A pre-release identifier.
        internal enum Identifier {
            /// A numeric pre-release identifier.
            /// - Parameter identifier: The identifier.
            case numeric(_ identifier: UInt)
            /// An alphanumeric pre-release identifier.
            /// - Parameter identifier: The identifier.
            case alphanumeric(_ identifier: String)
        }
    }
}

// MARK: - Initializers

extension SymbolGraph.SemanticVersion.Prerelease {
    /// Creates a semantic version pre-release from the given pre-release string.
    /// - Note: Empty string translates to an empty pre-release identifier, which is invalid.
    /// - Parameter dotSeparatedIdentifiers: The given pre-release string to create a semantic version pre-release from.
    /// - Throws: A `SymbolGraph.SemanticVersionError` instance if `dotSeparatedIdentifiers` is not a valid pre-release string.
    internal init(_ dotSeparatedIdentifiers: String?) throws {
        guard let dotSeparatedIdentifiers = dotSeparatedIdentifiers else {
            // FIXME: initialize 'identifiers' directly here after [SR-15670](https://bugs.swift.org/projects/SR/issues/SR-15670?filter=allopenissues) is resolved
            // currently 'identifiers' cannot be initialized directly because initializer delegation is flow-insensitive
            // self.identifiers = []
            self.init(identifiers: [])
            return
        }
        let identifiers = dotSeparatedIdentifiers.split(
            separator: ".",
            omittingEmptySubsequences: false // Preserve empty sequences to be able to raise validation errors about empty prerelease identifiers.
        )
        try self.init(identifiers)
    }
    
    /// Creates a semantic version pre-release from the given pre-release identifier strings.
    /// - Parameter identifiers: The given pre-release identifier strings to create a semantic version pre-release from.
    /// - Throws: A `SymbolGraph.SemanticVersionError` instance if any element of `identifiers` is not a valid pre-release identifier string.
    internal init<C: Collection, S: StringProtocol>(_ identifiers: C) throws where C.Element == S, S.SubSequence == Substring {
        self.identifiers = try identifiers.map {
            try Identifier($0)
        }
    }
}

extension SymbolGraph.SemanticVersion.Prerelease.Identifier {
    /// Creates a semantic version pre-release identifier from the given pre-release identifier string.
    /// - Parameter identifierString: The given pre-release identifier string to create a semantic version pre-release identifier from.
    /// - Throws: A `SymbolGraph.SemanticVersionError` instance if `identifierString` is not a valid pre-release identifier string.
    internal init<S: StringProtocol>(_ identifierString: S) throws where S.SubSequence == Substring {
        guard !identifierString.isEmpty else {
            throw SymbolGraph.SemanticVersionError.emptyIdentifier(position: .prerelease)
        }
        guard identifierString.allSatisfy(\.isAllowedInSemanticVersionIdentifier) else {
            throw SymbolGraph.SemanticVersionError.invalidCharacterInIdentifier(String(identifierString), position: .prerelease)
        }
        if identifierString.allSatisfy(\.isNumber) {
            // diagnose the identifier as a numeric identifier, if all characters are ASCII digits
            guard identifierString.first != "0" || identifierString == "0" else {
                throw SymbolGraph.SemanticVersionError.invalidNumericIdentifier(
                    String(identifierString),
                    position: .prerelease,
                    errorKind: .leadingZeros
                )
            }
            guard let numericIdentifier = UInt(identifierString) else {
                if identifierString.isEmpty {
                    throw SymbolGraph.SemanticVersionError.emptyIdentifier(position: .prerelease)
                } else {
                    throw SymbolGraph.SemanticVersionError.invalidNumericIdentifier(
                        String(identifierString),
                        position: .prerelease,
                        errorKind: .oversizedValue
                    )
                }
            }
            self = .numeric(numericIdentifier)
        } else {
            self = .alphanumeric(String(identifierString))
        }
    }
}

// MARK: - Comparable Conformances

// Compiler synthesised `Equatable`-conformance is correct here.
extension SymbolGraph.SemanticVersion.Prerelease: Comparable {
    internal static func <(lhs: Self, rhs: Self) -> Bool {
        guard !lhs.identifiers.isEmpty else { return false } // non-pre-release lhs >= potentially pre-release rhs
        guard !rhs.identifiers.isEmpty else { return true }  // pre-release lhs < non-pre-release rhs
        return lhs.identifiers.lexicographicallyPrecedes(rhs.identifiers)
    }
}

// Compiler synthesised `Equatable`-conformance is correct here.
extension SymbolGraph.SemanticVersion.Prerelease.Identifier: Comparable {
    internal static func <(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.numeric(lhs), .numeric(rhs)):
            return lhs < rhs
        case let(.alphanumeric(lhs), .alphanumeric(rhs)):
            return lhs < rhs
        case (.numeric, .alphanumeric):
            return true
        case (.alphanumeric, .numeric):
            return false
        }
    }
}

// MARK: CustomStringConvertible Conformances

extension SymbolGraph.SemanticVersion.Prerelease: CustomStringConvertible {
    /// A textual description of the pre-release.
    internal var description: String {
        identifiers.map(\.description).joined(separator: ".")
    }
}

extension SymbolGraph.SemanticVersion.Prerelease.Identifier: CustomStringConvertible {
    /// A textual description of the identifier.
    internal var description: String {
        switch self {
        case .numeric(let identifier):
            return identifier.description
        case .alphanumeric(let identifier):
            return identifier.description
        }
    }
}
