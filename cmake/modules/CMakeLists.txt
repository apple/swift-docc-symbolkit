#[[
This source file is part of the DocC open source project

Copyright (c) 2024 Apple Inc. and the DocC project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

set(SYMBOLKIT_EXPORTS_FILE
  ${CMAKE_CURRENT_BINARY_DIR}/SymbolKitExports.cmake)
configure_file(SymbolKitConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/SymbolKitConfig.cmake)

get_property(SYMBOLKIT_EXPORTS GLOBAL PROPERTY SYMBOLKIT_EXPORTS)
export(TARGETS ${SYMBOLKIT_EXPORTS}
  NAMESPACE DocC::
  FILE ${SYMBOLKIT_EXPORTS_FILE}
  EXPORT_LINK_INTERFACE_LIBRARIES)
