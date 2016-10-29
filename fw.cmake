include(CMakeParseArguments)

find_package(Git)

function(fw_c_flags)
  if (NOT CMAKE_C_FLAGS)
    set(CMAKE_C_FLAGS "${ARGN}" PARENT_SCOPE)
  else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${ARGN}" PARENT_SCOPE)
  endif()
endfunction()

function(fw_cxx_flags)
  if (NOT CMAKE_CXX_FLAGS)
    set(CMAKE_CXX_FLAGS "${ARGN}" PARENT_SCOPE)
  else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARGN}" PARENT_SCOPE)
  endif()
endfunction()

macro(fw_c_cxx_flags)
  fw_c_flags(${ARGN})
  fw_cxx_flags(${ARGN})
endmacro()

macro(fw_exe_linker_flags)
  if("${CMAKE_EXE_LINKER_FLAGS}" STREQUAL "")
    set(CMAKE_EXE_LINKER_FLAGS "${ARGN}")
  else()
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${ARGN}")
  endif()
endmacro()

function(fw_version_from_git out_version out_major out_minor out_patch)
  if(NOT GIT_FOUND)
    message(FATAL_ERROR "Can not get version - 'git' is not installed")
  endif()
  execute_process(
    COMMAND "${GIT_EXECUTABLE}" describe --tags --long
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    RESULT_VARIABLE retcode
    OUTPUT_VARIABLE version
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT retcode EQUAL 0)
    set(${version} "NOT-FOUND" PARENT_SCOPE)
    return()
  endif()
  string(REGEX REPLACE "v(\\.*)" "\\1" version ${version})
  string(REGEX REPLACE "([0-9]+)\\.[0-9]+\\.[0-9]+.*" "\\1" major ${version})
  string(REGEX REPLACE "[0-9]+\\.([0-9]+)\\.[0-9]+.*" "\\1" minor ${version})
  string(REGEX REPLACE "[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" patch ${version})
  foreach(i version major minor patch)
    set(${out_${i}} ${${i}} PARENT_SCOPE)
  endforeach()
endfunction()

function(fw_version_from_file filename out_version out_major out_minor out_patch)
  file(READ ${filename} content)
  string(STRIP ${content} content)
  set(version ${content})
  string(REGEX REPLACE ".*([0-9]+)\\.[0-9]+\\.[0-9]+.*" "\\1" major ${content})
  string(REGEX REPLACE ".*[0-9]+\\.([0-9]+)\\.[0-9]+.*" "\\1" minor ${content})
  string(REGEX REPLACE ".*[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" patch ${content})
  foreach(i version major minor patch)
    set(${out_${i}} ${${i}} PARENT_SCOPE)
  endforeach()
endfunction()

function(fw_page_size out)
  set(getpagesize "
#include <unistd.h>
#include <stdio.h>

int main()
{
  long sz = sysconf(_SC_PAGESIZE);
  printf(\"%lu\", sz);
  return 0;
}
")
  file(WRITE "${CMAKE_BINARY_DIR}/getpagesize/main.c" "${getpagesize}")
  enable_language(C)
  try_run(
    run_result_unused
    compile_result_unused
    "${CMAKE_BINARY_DIR}/getpagesize"
    "${CMAKE_BINARY_DIR}/getpagesize/main.c"
    RUN_OUTPUT_VARIABLE page_size)
  set(${out} ${page_size} PARENT_SCOPE)
endfunction()

function(fw_stack_size out)
  set(getstacksize "
#include <pthread.h>
#include <stdio.h>

int main()
{
  pthread_attr_t a;
  pthread_attr_init(&a);
  size_t size;
  pthread_attr_getstacksize(&a, &size);
  printf(\"%llu\", (unsigned long long) size);
  return 0;
}
")
  file(WRITE "${CMAKE_BINARY_DIR}/getstacksize/main.c" "${getstacksize}")
  enable_language(C)
  try_run(
    run_result_unused
    compile_result_unused
    "${CMAKE_BINARY_DIR}/getstacksize"
    "${CMAKE_BINARY_DIR}/getstacksize/main.c"
    CMAKE_FLAGS "-DLINK_LIBRARIES=pthread"
    RUN_OUTPUT_VARIABLE stack_size)
  set(${out} ${stack_size} PARENT_SCOPE)
endfunction()

function(fw_guard_size out)
  set(getguardsize "
#include <pthread.h>
#include <stdio.h>

int main()
{
  pthread_attr_t a;
  pthread_attr_init(&a);
  size_t size;
  pthread_attr_getguardsize(&a, &size);
  printf(\"%llu\", (unsigned long long) size);
  return 0;
}
")
  file(WRITE "${CMAKE_BINARY_DIR}/getguardsize/main.c" "${getguardsize}")
  enable_language(C)
  try_run(
    run_result_unused
    compile_result_unused
    "${CMAKE_BINARY_DIR}/getguardsize"
    "${CMAKE_BINARY_DIR}/getguardsize/main.c"
    CMAKE_FLAGS "-DLINK_LIBRARIES=pthread"
    RUN_OUTPUT_VARIABLE guard_size)
  set(${out} ${guard_size} PARENT_SCOPE)
endfunction()

function(fw_whoami out_var)
  if(NOT UNIX)
    message(FATAL_ERROR "Platform is not supported")
  endif()
  execute_process(
    COMMAND whoami OUTPUT_VARIABLE temp OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(${out_var} ${temp} PARENT_SCOPE)
endfunction()

function(fw_uname out_var)
  if(NOT UNIX)
    message(FATAL_ERROR "Platform is not supported")
  endif()
  execute_process(
    COMMAND uname -n OUTPUT_VARIABLE temp OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(${out_var} ${temp} PARENT_SCOPE)
endfunction()

function(fw_date out_var)
  if(NOT UNIX)
    message(FATAL_ERROR "Platform is not supported")
  endif()
  execute_process(
     COMMAND date +%Y.%m.%d OUTPUT_VARIABLE temp OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(${out_var} ${temp} PARENT_SCOPE)
endfunction()

function(_fw_deb_version)
  list(APPEND params
    VERSION_FILE
    VERSION_MAJOR
    VERSION_MINOR
    VERSION_PATCH
    VERSION_BUILD
    OUT
  )

  list(APPEND options
    GENERATE_VERSION_BUILD
  )

  cmake_parse_arguments("FW_DEB_VER" "${options}" "${params}" "" ${ARGN})

  if(NOT "${FW_DEB_VER_VERSION_FILE}" STREQUAL "")
    fw_version_from_file(${FW_DEB_VER_VERSION_FILE} _ FW_DEB_VER_VERSION_MAJOR FW_DEB_VER_VERSION_MINOR FW_DEB_VER_VERSION_PATCH)
  endif()

  if(${FW_DEB_VER_GENERATE_VERSION_BUILD} AND "${FW_DEB_VER_VERSION_BUILD}" STREQUAL "")
    fw_whoami(user)
    fw_uname(host)
    fw_date(date)
    set(FW_DEB_VER_VERSION_BUILD "${user}+${host}.${date}")
  endif()

  set(ver_out "${FW_DEB_VER_VERSION_MAJOR}.${FW_DEB_VER_VERSION_MINOR}.${FW_DEB_VER_VERSION_PATCH}")
  if(NOT "${FW_DEB_VER_VERSION_BUILD}" STREQUAL "")
    set(ver_out "${ver_out}.${FW_DEB_VER_VERSION_BUILD}")
  endif()
  set(${FW_DEB_VER_OUT} "${ver_out}" PARENT_SCOPE)
endfunction()

function(fw_deb)
  list(APPEND params
    NAME
    VERSION_FILE
    VERSION_MAJOR
    VERSION_MINOR
    VERSION_PATCH
    VERSION_BUILD
    PREINST
    POSTINST
    PRERM
    POSTRM
    CONFFILES
    DESCRIPTION
    VENDOR
    CONTACT
  )

  list(APPEND options
    GENERATE_VERSION_BUILD
  )

  list(APPEND mulparams
    DEPENDS
    CONFLICTS
    RECOMMENDS
  )

  cmake_parse_arguments("FW_DEB" "${options}" "${params}" "${mulparams}" ${ARGN})

  if("${FW_DEB_DESCRIPTION}" STREQUAL "")
    set(FW_DEB_DESCRIPTION "package ${FW_DEB_NAME}, provider by ${FW_DEB_VENDOR}")
  endif()

  if("${FW_DEB_VENDOR}" STREQUAL "")
    fw_whoami(user)
    set(FW_DEB_VENDOR "${user}")
  endif()

  if("${FW_DEB_CONTACT}" STREQUAL "")
    fw_whoami(user)
    fw_uname(host)
    set(FW_DEB_CONTACT "${user}@${host}")
  endif()

  fw_debian_architecture(deb_arch)
  if(${FW_DEB_GENERATE_VERSION_BUILD})
    _fw_deb_version(
      VERSION_FILE "${FW_DEB_VERSION_FILE}"
      VERSION_MAJOR "${FW_DEB_VERSION_MAJOR}"
      VERSION_MINOR "${FW_DEB_VERSION_MINOR}"
      VERSION_PATCH "${FW_DEB_VERSION_PATCH}"
      VERSION_BUILD "${FW_DEB_VERSION_BUILD}"
      GENERATE_VERSION_BUILD
      OUT deb_version
    )
  else()
    _fw_deb_version(
      VERSION_FILE "${FW_DEB_VERSION_FILE}"
      VERSION_MAJOR "${FW_DEB_VERSION_MAJOR}"
      VERSION_MINOR "${FW_DEB_VERSION_MINOR}"
      VERSION_PATCH "${FW_DEB_VERSION_PATCH}"
      VERSION_BUILD "${FW_DEB_VERSION_BUILD}"
      OUT deb_version
    )
  endif()

  set(CPACK_PACKAGE_NAME "${FW_DEB_NAME}" PARENT_SCOPE)
  set(CPACK_GENERATOR "DEB" PARENT_SCOPE)
  set(CPACK_BINARY_DEB "ON" PARENT_SCOPE)
  set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${deb_arch}" PARENT_SCOPE)
  set(CPACK_PACKAGE_VERSION "${deb_version}" PARENT_SCOPE)
  set(CPACK_PACKAGE_FILE_NAME "${FW_DEB_NAME}_${deb_version}_${deb_arch}" PARENT_SCOPE)
  set(CPACK_PACKAGE_VERSION_MAJOR "${FW_DEB_VERSION_MAJOR}" PARENT_SCOPE)
  set(CPACK_PACKAGE_VERSION_MINOR "${FW_DEB_VERSION_MINOR}" PARENT_SCOPE)
  set(CPACK_PACKAGE_VERSION_PATCH "${FW_DEB_VERSION_PATCH}" PARENT_SCOPE)
  set(CPACK_DEBIAN_PACKAGE_CONFLICTS "${FW_DEB_CONFLICTS}" PARENT_SCOPE)
  set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${FW_DEB_PREINST};${FW_DEB_POSTINST};${FW_DEB_PRERM};${FW_DEB_POSTRM};${FW_DEB_CONFFILES}" PARENT_SCOPE)
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${FW_DEB_DESCRIPTION}" PARENT_SCOPE)
  set(CPACK_DEBIAN_PACKAGE_DEPENDS "${FW_DEB_DEPENDS}" PARENT_SCOPE)
  set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "${FW_DEB_RECOMMENDS}" PARENT_SCOPE)
  set(CPACK_PACKAGE_VENDOR "${FW_DEB_VENDOR}" PARENT_SCOPE)
  set(CPACK_PACKAGE_CONTACT "${FW_DEB_CONTACT}" PARENT_SCOPE)
endfunction()

# Install "sympath -> filepath" symlink
macro(fw_install_symlink filepath sympath)
  get_filename_component(symname ${sympath} NAME)
  get_filename_component(installdir ${sympath} PATH)

  execute_process(
    COMMAND "${CMAKE_COMMAND}" -E create_symlink
    ${filepath}
    ${CMAKE_CURRENT_BINARY_DIR}/${symname})
  install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/${symname}
    DESTINATION ${installdir}
    ${ARGN})
endmacro()

function(fw_exports target exports_file)
  if(NOT UNIX)
    message(FATAL_ERROR "Platform is not supported")
  endif()
  if(NOT(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
    message(FATAL_ERROR "Compiler is not supported")
  endif()
  set(make_exports_sh_content "#!/usr/bin/env bash

compiler=$1
library=$2

case \"$compiler\" in
\"clang\")
  while read -r; do
    if [ -n \"$REPLY\" ]; then
      echo \"_$REPLY\"
    fi
  done
;;
\"gcc\")
  echo \"$library {\"
  echo \"  global:\"
  while read -r; do
    if [ -n \"$REPLY\" ]; then
      echo \"    $REPLY;\"
    fi
  done
  echo \"  local: *;\"
  echo \"};\"
;;
*)
  >&2 echo \"did not understand being called with \\\"$1\\\"\"
  exit 1
;;
esac
")
  set(make_exports_sh "${CMAKE_BINARY_DIR}/make_exports.sh")
  if(NOT EXISTS ${make_exports_sh})
    file(WRITE ${make_exports_sh} "${make_exports_sh_content}")
  endif()
  if(NOT EXISTS ${exports_file} AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${exports_file}")
    set(exports_file "${CMAKE_CURRENT_SOURCE_DIR}/${exports_file}")
  endif()
  set(dot_version_file ${CMAKE_CURRENT_BINARY_DIR}/${target}.version)
  set(dot_map_file ${CMAKE_CURRENT_BINARY_DIR}/${target}.map)
  execute_process(
    COMMAND bash ${make_exports_sh} gcc ${target}
    INPUT_FILE ${exports_file}
    OUTPUT_FILE ${dot_version_file})
  execute_process(
    COMMAND bash ${make_exports_sh} clang ${target}
    INPUT_FILE ${exports_file}
    OUTPUT_FILE ${dot_map_file})
  if(CMAKE_COMPILER_IS_GNUCXX)
    set_target_properties(${target} PROPERTIES LINK_FLAGS "-Wl,--version-script=${dot_version_file}")
  endif()
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set_target_properties(${target} PROPERTIES LINK_FLAGS "-Wl,-exported_symbols_list,${dot_map_file}")
  endif()
endfunction()
