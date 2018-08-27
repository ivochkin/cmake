include(FindPackageHandleStandardArgs)

find_path(LIBYAML_INCLUDE_DIRS NAMES yaml.h DOC "Directory for libyaml headers")
find_library(LIBYAML_LIBRARIES NAMES yaml libyaml)

find_package_handle_standard_args(yaml DEFAULT_MSG LIBYAML_LIBRARIES LIBYAML_INCLUDE_DIRS)
mark_as_advanced(LIBYAML_INCLUDE_DIRS LIBYAML_LIBRARIES)
