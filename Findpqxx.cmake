include(FindPackageHandleStandardArgs)

find_path(PQXX_INCLUDE_DIRS
    NAME
        pqxx
    PATH_SUFFIXES
        pqxx
    DOC
        "Directory for pqxx headers"
)

find_library(PQXX_LIBRARIES
    NAMES pqxx
)

FIND_PACKAGE_HANDLE_STANDARD_ARGS("PQXX"
    "libpqxx couldn't be found"
    PQXX_LIBRARIES
    PQXX_INCLUDE_DIRS
)
