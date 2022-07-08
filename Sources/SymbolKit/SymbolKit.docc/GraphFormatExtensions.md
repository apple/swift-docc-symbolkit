# Extending the Symbol Graph Format

Define custom Symbol or Relationship kinds and store custom information in the graph.

## Overview

SymbolKit makes it easy to parse Symbol Graph Files and inspect or edit the resulting graph's _contents_. However, sometimes you migth want to go beyond that by changing the _structure_ of the graph. SymbolKit allows you to define custom Symbol and Relationship kinds and lets you extend nodes and edges with custom properties.

## Defining Custom Symbol or Relationship Kinds

To define a custom ``SymbolGraph/Symbol/KindIdentifier`` or ``SymbolGraph/Relationship/Kind-swift.struct``, first create a static constant using the initializers ``SymbolGraph/Symbol/KindIdentifier/init(rawValue:)`` or ``SymbolGraph/Relationship/Kind-swift.struct/init(rawValue:)``, respectively.

Make sure to **not** include a language prefix such as `"swift."` here for Symbol kinds!

```swift
extension SymbolGraph.Symbol.KindIdentifier {
    static let extendedModule = KindIdentifier(rawValue: "module.extension")
}

extension SymbolGraph.Relationship.Kind {
    static let extensionTo = Kind(rawValue: "extensionTo")
}
```

Use these constants when manually initializing Symbols/Relationships of the respective kind instead of initilaizing new instances of ``SymbolGraph/Symbol/KindIdentifier`` / ``SymbolGraph/Relationship/Kind-swift.struct`` all the time.

After defining a custom Symbol kind, make sure to register it using ``SymbolGraph/Symbol/KindIdentifier/register(_:)``. This ensures all static functionality defined on ``SymbolGraph/Symbol/KindIdentifier`` works as expected.

```swift
SymbolGraph.Symbol.KindIdentifier.register(.extendedModule)

// true
print(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("swift.module.extension"))
```

## Defining Custom Properties

The key to storing arbitrary information on Symbols or Relationships is the ``Mixin`` protocol.

Start out by defining the information you want to capture:

```swift
/// Commit metadata of the last commit that modified this Symbol.
struct LastCommit: Mixin, Hashable {
    static let mixinKey = "lastCommit"    

    let hash: String
    let date: Date
    let authorName: String
    let authorEmail: String
}
```

You might want to extend Symbol/Relationship for easier access:

```swift
extension SymbolGraph.Symbol {
    var lastCommit: LastCommit? {
        get {
            self[mixin: LastCommit.self]
        }
        set {
            self[mixin: LastCommit.self] = newValue
        }
    }
}
```

You can now easily edit this information on an existing Symbol Graph.

Before you can encode and decode this information, you need to register your custom Mixin on your encoder/decoder using ``CustomizableCoder/register(symbolMixins:)`` / ``CustomizableCoder/register(relationshipMixins:)``, respectively. If you forget this step, you custom mixins will be ignored!

```swift
// prepare encoder and decoder to deal with custom mixin
let decoder = JSONDecoder()
decoder.register(symbolMixins: LastCommit.self)

let encoder = JSONEncoder()
encoder.register(symbolMixins: LastCommit.self)

// decode graph
var graph = try decoder.decode(SymbolGraph.self, from: inputData)

// modify graph ...

// encode graph
let outputData = try encoder.encode(graph)
```

## Topics

### Defining Custom Symbol or Relationship Kinds

- ``SymbolGraph/Symbol/KindIdentifier``
- ``SymbolGraph/Symbol/KindIdentifier/init(rawValue:)``
- ``SymbolGraph/Symbol/KindIdentifier/register(_:)``
- ``CustomizableCoder/register(symbolKinds:)``
- ``SymbolGraph/Relationship/Kind-swift.struct``
- ``SymbolGraph/Relationship/Kind-swift.struct/init(rawValue:)``

### Defining Custom Properties

- ``Mixin``
- ``CustomizableCoder/register(symbolMixins:)``
- ``CustomizableCoder/register(relationshipMixins:)``
- ``CustomizableCoder``

<!-- Copyright (c) 2021-2022 Apple Inc and the Swift Project authors. All Rights Reserved. -->
