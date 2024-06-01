/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

extension SymbolGraph.SemanticVersion: CustomStringConvertible {
    /// A textual description of the semantic version.
    public var description: String {
        var versionString = "\(major).\(minor).\(patch)"
        if !prerelease.identifiers.isEmpty {
            versionString += "-\(prerelease)"
        }
        if !buildMetadataIdentifiers.isEmpty {
            versionString += "+" + buildMetadataIdentifiers.joined(separator: ".")
        }
        return versionString
    }
}
