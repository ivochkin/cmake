# This module defines
#
#   SOL_FOUND
#   SOL_INCLUDE_DIRS


find_path(SOL_INCLUDE_DIR NAMES
  sol.hpp
)

find_package_handle_standard_args(SOL DEFAULT_MSG
  SOL_INCLUDE_DIR
)

mark_as_advanced(
  SOL_INCLUDE_DIRS
)
