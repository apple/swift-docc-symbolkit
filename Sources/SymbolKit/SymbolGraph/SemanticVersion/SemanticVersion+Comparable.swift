/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

extension SymbolGraph.SemanticVersion: Comparable {
    // Although `Comparable` inherits from `Equatable`, it does not provide a new default implementation of `==`, but instead uses `Equatable`'s default synthesised implementation. The compiler-synthesised `==`` is composed of [member-wise comparisons](https://github.com/apple/swift-evolution/blob/main/proposals/0185-synthesize-equatable-hashable.md#implementation-details), which leads to a false `false` when 2 semantic versions differ by only their build metadata identifiers, contradicting SemVer 2.0.0's [comparison rules](https://semver.org/#spec-item-10).
    // [SR-14665](https://github.com/apple/swift/issues/57016)
    /// Returns a Boolean value indicating whether two semantic versions are equal.
    /// - Parameters:
    ///   - lhs: A semantic version to compare.
    ///   - rhs: Another semantic version to compare.
    /// - Returns: `true` if `lhs` and `rhs` are equal; `false` otherwise.
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        !(lhs < rhs) && !(lhs > rhs)
    }
    
    /// Returns a Boolean value indicating whether the first semantic version precedes the second semantic version.
    /// - Parameters:
    ///   - lhs: A semantic version to compare.
    ///   - rhs: Another semantic version to compare.
    /// - Returns: `true` if `lhs` precedes `rhs`; `false` otherwise.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        let lhsVersionCore = [lhs.major, lhs.minor, lhs.patch]
        let rhsVersionCore = [rhs.major, rhs.minor, rhs.patch]
        
        guard lhsVersionCore == rhsVersionCore else {
            return lhsVersionCore.lexicographicallyPrecedes(rhsVersionCore)
        }
        
        return lhs.prerelease < rhs.prerelease // not lexicographically compared
    }
}
