/*
 This source file is part of the Swift.org open source project
 
 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

extension Character {
    /// A Boolean value indicating whether this character is allowed in a semantic version's identifier.
    internal var isAllowedInSemanticVersionIdentifier: Bool {
        isASCII && (isLetter || isNumber || self == "-")
    }
    
    /// A Boolean value indicating whether this character is allowed in a semantic version's numeric identifier.
    internal var isAllowedInSemanticVersionNumericIdentifier: Bool {
        isASCII && isNumber
    }
}
