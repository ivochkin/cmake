# cmake
Top-level cmake directory to share across c/c++ projects

## Find modules
A bunch of Find modules, handwritten or borrowed from other projects, including:

* libuv (https://github.com/libuv/libuv)
* http-parser (https://github.com/nodejs/http-parser)
* yaml-cpp (https://github.com/jbeder/yaml-cpp)

## fw.cmake
Contains a bunch of useful functions that extend CMake functionality and/or provide handy shortcuts to common commands.

Functions:

* fw_c_flags
* fw_cxx_flags
* fw_c_cxx_flags
* fw_exe_linker_flags
* fw_version_from_git
* fw_version_from_file
* fw_page_size
* fw_stack_size
* fw_guard_size
* fw_whoami
* fw_uname
* fw_date
* fw_deb
* fw_install_symlink
