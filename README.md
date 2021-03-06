# cmake
Top-level cmake directory to share across c/c++ projects

## Find modules
A bunch of Find modules, handwritten or borrowed from other projects, including:

* libuv (https://github.com/libuv/libuv)
* http-parser (https://github.com/nodejs/http-parser)
* yaml-cpp (https://github.com/jbeder/yaml-cpp)
* pqxx (https://github.com/jtv/libpqxx)
* dfk (https://github.com/ivochkin/dfk) + dfkcpp (C++ bindings)
* memcached (https://github.com/memcached/memcached)

## fw.cmake
Contains a bunch of useful functions that extend CMake functionality and/or provide handy shortcuts to common commands.

Functions:

* `fw_join`
* `fw_c_flags`
* `fw_cxx_flags`
* `fw_c_cxx_flags`
* `fw_exe_linker_flags`
* `fw_version_from_git`
* `fw_version_from_file`
* `fw_page_size`
* `fw_stack_size`
* `fw_guard_size`
* `fw_malloc_alignment`
* `fw_whoami`
* `fw_uname`
* `fw_date`
* `fw_time`
* `fw_target_architecture`
* `fw_debian_architecture`
* `fw_deb`
* `fw_install_symlink`
* `fw_exports`
* `fw_c99`
* `fw_c11`
* `fw_default_build_type`
* `fw_forbid_in_source_build`
* `fw_graphviz`
* `fw_target_sources`
* `fw_gtest`
