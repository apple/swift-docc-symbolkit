#[[
This source file is part of the DocC open source project

Copyright (c) 2024 Apple Inc. and the DocC project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_library(SymbolKit
  Mixin/Mixin+Equals.swift
  Mixin/Mixin+Hash.swift
  Mixin/Mixin.swift
  SymbolGraph/AnyScalar.swift
  SymbolGraph/Metadata.swift
  SymbolGraph/Module.swift
  SymbolGraph/OperatingSystem.swift
  SymbolGraph/Platform.swift
  SymbolGraph/SemanticVersion.swift
  SymbolGraph/SymbolGraph.swift
  SymbolGraph/LineList/LineList.swift
  SymbolGraph/LineList/SourceRange/Position.swift
  SymbolGraph/LineList/SourceRange/SourceRange.swift
  SymbolGraph/Relationship/ReferenceLocation.swift
  SymbolGraph/Relationship/Relationship.swift
  SymbolGraph/Relationship/RelationshipKind.swift
  SymbolGraph/Relationship/SourceOrigin.swift
  SymbolGraph/Relationship/Swift/GenericConstraints.swift
  SymbolGraph/Relationship/Swift/Swift.swift
  SymbolGraph/Symbol/AccessControl.swift
  SymbolGraph/Symbol/AlternateDeclarations.swift
  SymbolGraph/Symbol/Identifier.swift
  SymbolGraph/Symbol/KindIdentifier.swift
  SymbolGraph/Symbol/Location.swift
  SymbolGraph/Symbol/Mutability.swift
  SymbolGraph/Symbol/Names.swift
  SymbolGraph/Symbol/Snippet.swift
  SymbolGraph/Symbol/SPI.swift
  SymbolGraph/Symbol/Symbol.swift
  SymbolGraph/Symbol/SymbolKind.swift
  SymbolGraph/Symbol/ValueConstraints.swift
  SymbolGraph/Symbol/Availability/Availability.swift
  SymbolGraph/Symbol/Availability/AvailabilityItem.swift
  SymbolGraph/Symbol/Availability/Domain.swift
  SymbolGraph/Symbol/DeclarationFragments/DeclarationFragments.swift
  SymbolGraph/Symbol/DeclarationFragments/Fragment/Fragment.swift
  SymbolGraph/Symbol/DeclarationFragments/Fragment/FragmentKind.swift
  SymbolGraph/Symbol/FunctionSignature/FunctionParameter.swift
  SymbolGraph/Symbol/FunctionSignature/FunctionSignature.swift
  SymbolGraph/Symbol/HTTP/HTTP.swift
  SymbolGraph/Symbol/Swift/Extension.swift
  SymbolGraph/Symbol/Swift/GenericConstraint.swift
  SymbolGraph/Symbol/Swift/GenericParameter.swift
  SymbolGraph/Symbol/Swift/Generics.swift
  SymbolGraph/Symbol/Swift/Namespace.swift
  UnifiedSymbolGraph/GraphCollector.swift
  UnifiedSymbolGraph/UnifiedSymbol+Encodable.swift
  UnifiedSymbolGraph/UnifiedSymbol.swift
  UnifiedSymbolGraph/UnifiedSymbolGraph+Encodable.swift
  UnifiedSymbolGraph/UnifiedSymbolGraph.swift)
set_target_properties(SymbolKit PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})

set_property(GLOBAL APPEND PROPERTY SYMBOLKIT_EXPORTS SymbolKit)
