/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation

extension SymbolGraph.Symbol {
    /**
     The place where a symbol was originally declared in a source file.

     This information may not always be available for many reasons, such
     as compiler infrastructure limitations, or filesystem security concerns.
     */
    public struct Location: Mixin {
        public static let mixinKey = "location"

        /**
         The URI of the file in which the symbol was originally declared,
         suitable for display in a user interface.
         */
        public var uri: String

        /**
         The file URL of the source file where the symbol was originally declared.
         */
        @available(macOS 10.11, *)
        public var url: URL? {
            // The URI string provided in the symbol graph file may be an invalid URL (rdar://69242070)
            //
            // Using `URL.init(dataRepresentation:relativeTo:)` here handles URI strings with unescaped
            // characters without trying to escape or otherwise process the URI string in SymbolKit.
            URL(dataRepresentation: Data(uri.utf8), relativeTo: nil)
        }
        
        /**
         The range of the declaration in the file, not including its documentation comment.
         */
        public var position: SymbolGraph.LineList.SourceRange.Position
        
        /**
         Creates a new symbol location with the given source file URI and position.
         */
        public init(uri: String, position: SymbolGraph.LineList.SourceRange.Position) {
            self.uri = uri
            self.position = position
        }
    }
}
