/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

extension SymbolGraph.SemanticVersion: Codable {
    internal enum CodingKeys: String, CodingKey {
        case major
        case minor
        case patch
        case prerelease
        case buildMetadata
    }
    
    /// Creates a semantic version by decoding from the given decoder.
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let major = try container.decode(UInt.self, forKey: .major)
        let minor = try container.decodeIfPresent(UInt.self, forKey: .minor) ?? 0
        let patch = try container.decodeIfPresent(UInt.self, forKey: .patch) ?? 0
        let prerelease = try container.decodeIfPresent(String.self, forKey: .prerelease)
        let buildMetadata = try container.decodeIfPresent(String.self, forKey: .buildMetadata)
        try self.init(
            major: major,
            minor: minor,
            patch: patch,
            prerelease: prerelease,
            buildMetadata: buildMetadata
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(major, forKey: .major)
        try container.encode(minor, forKey: .minor)
        try container.encode(patch, forKey: .patch)
        
        if denotesPrerelease {
            try container.encode(prerelease.description, forKey: .prerelease)
        }
        
        if !buildMetadataIdentifiers.isEmpty {
            try container.encode(buildMetadataIdentifiers.joined(separator: "."), forKey: .buildMetadata)
        }
    }
}
