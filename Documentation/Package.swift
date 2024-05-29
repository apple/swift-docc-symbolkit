// swift-tools-version:5.6
/*
 This source file is part of the Swift.org open source project
 Copyright (c) 2023 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import PackageDescription

let package = Package(
    name: "Documentation",
    dependencies: [
        .package(name: "SymbolKit", path: "../."),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "Empty",
            dependencies: [
                .product(name: "SymbolKit", package: "SymbolKit"),
            ],
            path: "Empty"
        )
    ]
)
