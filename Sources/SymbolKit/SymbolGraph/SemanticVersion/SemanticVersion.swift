/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 - 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

extension SymbolGraph {
    /// A [semantic version](https://semver.org).
    public struct SemanticVersion {
        /// The major version.
        public let major: UInt
        /// The minor version.
        public let minor: UInt
        /// The patch version.
        public let patch: UInt
        /// Dot-separated pre-release identifiers.
        public var prereleaseIdentifiers: [String] { prerelease.identifiers.map(\.description) }
        /// Dot-separated build metadata identifiers.
        public let buildMetadataIdentifiers: [String]
        
        /// The internal storage of pre-release identifiers.
        internal let prerelease: Prerelease
        
        /// Creates a semantic version with the provided components of a semantic version.
        /// - Parameters:
        ///   - major: The major version number.
        ///   - minor: The minor version number.
        ///   - patch: The patch version number.
        ///   - prerelease: The pre-release information.
        ///   - buildMetadata: The build metadata.
        public init(
            major: UInt,
            minor: UInt,
            patch: UInt,
            prerelease: String? = nil,
            buildMetadata: String? = nil
        ) throws {
            self.major = major
            self.minor = minor
            self.patch = patch
            
            let prereleaseIdentifiers = prerelease?.split(separator: ".", omittingEmptySubsequences: false) ?? []
            self.prerelease = try Prerelease(prereleaseIdentifiers)
            
            let buildMetadataIdentifiers = buildMetadata?.split(separator: ".", omittingEmptySubsequences: false).map { String($0) } ?? []
            guard buildMetadataIdentifiers.allSatisfy( { !$0.isEmpty } ) else {
                throw SymbolGraph.SemanticVersionError.emptyIdentifier(position: .buildMetadata)
            }
            try buildMetadataIdentifiers.forEach {
                guard $0.allSatisfy(\.isAllowedInSemanticVersionIdentifier) else {
                    throw SymbolGraph.SemanticVersionError.invalidCharacterInIdentifier($0, position: .buildMetadata)
                }
            }
            self.buildMetadataIdentifiers = buildMetadataIdentifiers
        }
        
        /// Creates a semantic version with the provided components of a semantic version.
        /// - Parameters:
        ///   - major: The major version number.
        ///   - minor: The minor version number.
        ///   - patch: The patch version number.
        ///   - prerelease: The pre-release information.
        ///   - buildMetadata: The build metadata.
        @available(*, deprecated, renamed: "init(_:_:_:prerelease:buildMetadata:)")
        @_disfavoredOverload
        public init(
            major: Int,
            minor: Int,
            patch: Int,
            prerelease: String? = nil,
            buildMetadata: String? = nil
        ) {
            try! self.init(
                major: UInt(major),
                minor: UInt(minor),
                patch: UInt(patch),
                prerelease: prerelease,
                buildMetadata: buildMetadata
            )
        }
        
        /// Creates a semantic version with the provided components of a semantic version.
        /// - Parameters:
        ///   - major: The major version number.
        ///   - minor: The minor version number.
        ///   - patch: The patch version number.
        public init(_ major: UInt, _ minor: UInt, _ patch: UInt) {
            try! self.init(major: major, minor: minor, patch: patch)
        }
    }
}

// MARK: - Inspecting the Semantics

extension SymbolGraph.SemanticVersion {
    /// A Boolean value indicating whether the version is for a pre-release.
    public var denotesPrerelease: Bool { !prerelease.identifiers.isEmpty }
    
    /// A Boolean value indicating whether the version is for a stable release.
    public var denotesStableRelease: Bool { major > 0 && !denotesPrerelease }
    
    /// Returns a Boolean value indicating whether a release with this version can introduce source-breaking changes from that with the given other version.
    /// - Parameter other: The older version a release with which to check if a release with the current version is allowed to source-break from.
    /// - Returns: A Boolean value indicating whether a release with this version can introduce source-breaking changes from that with `other`.
    public func denotesSourceBreakableRelease(fromThatWith other: Self) -> Bool {
        self > other && (
            self.major != other.major ||
            self.major == 0 || // When self.major == 0, other.major must also == 0 here.
            (self.denotesPrerelease || other.denotesPrerelease)
        )
    }
}

// MARK: - Creating a Version Semantically

extension SymbolGraph.SemanticVersion {
    /// The version that denotes the initial stable release.
    public static var initialStableReleaseVersion: Self {
        try! Self(major: 1, minor: 0, patch: 0)
    }
    
    /// Returns the version denoting the next major release that comes after the release denoted with the given version.
    /// - Parameter version: The version after which the version that denotes the next major release may come.
    /// - Returns: The version denoting the next major release that comes after the release denoted with `version`.
    public func nextMajorReleaseVersion(from version: Self) -> Self {
        if version.denotesPrerelease && version.major > 0 && version.minor == 0 && version.patch == 0 {
            return try! Self(major: version.major, minor: 0, patch: 0)
        } else {
            return try! Self(major: version.major + 1, minor: 0, patch: 0)
        }
    }
}
