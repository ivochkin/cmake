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

function(fw_time out_var)
  if(NOT UNIX)
    message(FATAL_ERROR "Platform is not supported")
  endif()
  execute_process(
     COMMAND date +%X OUTPUT_VARIABLE temp OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(${out_var} ${temp} PARENT_SCOPE)
endfunction()

function(fw_target_architecture output_var)
  set(archdetect_c_code "
#if defined(__arm__) || defined(__TARGET_ARCH_ARM)
    #if defined(__ARM_ARCH_7__) \\
        || defined(__ARM_ARCH_7A__) \\
        || defined(__ARM_ARCH_7R__) \\
        || defined(__ARM_ARCH_7M__) \\
        || (defined(__TARGET_ARCH_ARM) && __TARGET_ARCH_ARM-0 >= 7)
        #error cmake_ARCH armv7
    #elif defined(__ARM_ARCH_6__) \\
        || defined(__ARM_ARCH_6J__) \\
        || defined(__ARM_ARCH_6T2__) \\
        || defined(__ARM_ARCH_6Z__) \\
        || defined(__ARM_ARCH_6K__) \\
        || defined(__ARM_ARCH_6ZK__) \\
        || defined(__ARM_ARCH_6M__) \\
        || (defined(__TARGET_ARCH_ARM) && __TARGET_ARCH_ARM-0 >= 6)
        #error cmake_ARCH armv6
    #elif defined(__ARM_ARCH_5TEJ__) \\
        || (defined(__TARGET_ARCH_ARM) && __TARGET_ARCH_ARM-0 >= 5)
        #error cmake_ARCH armv5
    #else
        #error cmake_ARCH arm
    #endif
#elif defined(__i386) || defined(__i386__) || defined(_M_IX86)
    #error cmake_ARCH i386
#elif defined(__x86_64) || defined(__x86_64__) || defined(__amd64) || defined(_M_X64)
    #error cmake_ARCH x86_64
#elif defined(__ia64) || defined(__ia64__) || defined(_M_IA64)
    #error cmake_ARCH ia64
#elif defined(__ppc__) || defined(__ppc) || defined(__powerpc__) \\
      || defined(_ARCH_COM) || defined(_ARCH_PWR) || defined(_ARCH_PPC)  \\
      || defined(_M_MPPC) || defined(_M_PPC)
    #if defined(__ppc64__) || defined(__powerpc64__) || defined(__64BIT__)
        #error cmake_ARCH ppc64
    #else
        #error cmake_ARCH ppc
    #endif
#endif

#error cmake_ARCH unknown
  ")

  if(APPLE AND CMAKE_OSX_ARCHITECTURES)
    # On OS X we use CMAKE_OSX_ARCHITECTURES *if* it was set
    # First let's normalize the order of the values

    # Note that it's not possible to compile PowerPC applications if you are using
    # the OS X SDK version 10.6 or later - you'll need 10.4/10.5 for that, so we
    # disable it by default
    # See this page for more information:
    # http://stackoverflow.com/questions/5333490/how-can-we-restore-ppc-ppc64-as-well-as-full-10-4-10-5-sdk-support-to-xcode-4

    # Architecture defaults to i386 or ppc on OS X 10.5 and earlier, depending on the CPU type detected at runtime.
    # On OS X 10.6+ the default is x86_64 if the CPU supports it, i386 otherwise.

    foreach(osx_arch ${CMAKE_OSX_ARCHITECTURES})
      if("${osx_arch}" STREQUAL "ppc" AND ppc_support)
        set(osx_arch_ppc TRUE)
      elseif("${osx_arch}" STREQUAL "i386")
        set(osx_arch_i386 TRUE)
      elseif("${osx_arch}" STREQUAL "x86_64")
        set(osx_arch_x86_64 TRUE)
      elseif("${osx_arch}" STREQUAL "ppc64" AND ppc_support)
        set(osx_arch_ppc64 TRUE)
      else()
        message(FATAL_ERROR "Invalid OS X arch name: ${osx_arch}")
      endif()
    endforeach()

    # Now add all the architectures in our normalized order
    if(osx_arch_ppc)
      list(APPEND ARCH ppc)
    endif()

    if(osx_arch_i386)
      list(APPEND ARCH i386)
    endif()

    if(osx_arch_x86_64)
      list(APPEND ARCH x86_64)
    endif()

    if(osx_arch_ppc64)
      list(APPEND ARCH ppc64)
    endif()
  else()
    file(WRITE "${CMAKE_BINARY_DIR}/arch.c" "${archdetect_c_code}")

    enable_language(C)

    # Detect the architecture in a rather creative way...
    # This compiles a small C program which is a series of ifdefs that selects a
    # particular #error preprocessor directive whose message string contains the
    # target architecture. The program will always fail to compile (both because
    # file is not a valid C program, and obviously because of the presence of the
    # #error preprocessor directives... but by exploiting the preprocessor in this
    # way, we can detect the correct target architecture even when cross-compiling,
    # since the program itself never needs to be run (only the compiler/preprocessor)
    try_run(
      run_result_unused
      compile_result_unused
      "${CMAKE_BINARY_DIR}"
      "${CMAKE_BINARY_DIR}/arch.c"
      COMPILE_OUTPUT_VARIABLE ARCH
      CMAKE_FLAGS CMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
    )

    # Parse the architecture name from the compiler output
    string(REGEX MATCH "cmake_ARCH ([a-zA-Z0-9_]+)" ARCH "${ARCH}")

    # Get rid of the value marker leaving just the architecture name
    string(REPLACE "cmake_ARCH " "" ARCH "${ARCH}")

    # If we are compiling with an unknown architecture this variable should
    # already be set to "unknown" but in the case that it's empty (i.e. due
    # to a typo in the code), then set it to unknown
    if (NOT ARCH)
      set(ARCH unknown)
    endif()
  endif()

  set(${output_var} "${ARCH}" PARENT_SCOPE)
endfunction()

function(fw_debian_architecture output_var)
  fw_target_architecture(target_arch)
  if("${target_arch}" STREQUAL "x86_64")
    set(target_arch "amd64")
  endif()
  set(${output_var} "${target_arch}" PARENT_SCOPE)
endfunction()

function(_fw_deb_version)
  set(params "")
  list(APPEND params
    VERSION_FILE
    VERSION_MAJOR
    VERSION_MINOR
    VERSION_PATCH
    VERSION_BUILD
    OUT
  )

  set(options "")
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
  set(params "")
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

  set(options "")
  list(APPEND options
    GENERATE_VERSION_BUILD
  )

  set(mulparams "")
  list(APPEND mulparams
    DEPENDS
    CONFLICTS
    RECOMMENDS
  )

  cmake_parse_arguments("FW_DEB" "${options}" "${params}" "${mulparams}" ${ARGN})

  if("${FW_DEB_NAME}" STREQUAL "")
    set(FW_DEB_NAME ${CMAKE_PROJECT_NAME})
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

  if("${FW_DEB_DESCRIPTION}" STREQUAL "")
    fw_date(date)
    fw_time(time)
    list(APPEND props "Configured at ${date} ${time}")
    list(APPEND props "Install prefix: ${CMAKE_INSTALL_PREFIX}")
    list(APPEND props "CMake build type - '${CMAKE_BUILD_TYPE}'")
    list(APPEND props "CMake version - ${CMAKE_VERSION}")
    list(APPEND props "Compiled on ${CMAKE_SYSTEM}")
    list(APPEND props "C compiler ${CMAKE_C_COMPILER}")
    list(APPEND props "C compiler flags: ${CMAKE_C_FLAGS}")
    list(APPEND props "C compiler flags (Debug): ${CMAKE_C_FLAGS_DEBUG}")
    list(APPEND props "C compiler flags (Release): ${CMAKE_C_FLAGS_RELEASE}")
    list(APPEND props "C compiler flags (RelWithDebInfo): ${CMAKE_C_FLAGS_RELWITHDEBINFO}")
    list(APPEND props "C++ compiler ${CMAKE_CXX_COMPILER}")
    list(APPEND props "C++ compiler flags: ${CMAKE_CXX_FLAGS}")
    list(APPEND props "C++ compiler flags (Debug): ${CMAKE_CXX_FLAGS_DEBUG}")
    list(APPEND props "C++ compiler flags (Release): ${CMAKE_CXX_FLAGS_RELEASE}")
    list(APPEND props "C++ compiler flags (RelWithDebInfo): ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
    string(REPLACE ";" "\n  " description "${props}")
    set(FW_DEB_DESCRIPTION "Package '${FW_DEB_NAME}'\n  ${description}")
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
  set(CPACK_PACKAGING_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" PARENT_SCOPE)
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

function(fw_c99)
  if(CMAKE_VERSION VERSION_LESS "3.1")
    fw_c_flags("--std=c99")
    set(CMAKE_C_FLAGS ${CMAKE_C_FLAGS} PARENT_SCOPE)
  else()
    set(CMAKE_C_STANDARD 99 PARENT_SCOPE)
  endif()
endfunction()

function(fw_default_build_type type)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE ${type} CACHE STRING
    "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel." FORCE PARENT_SCOPE)
endif()
endfunction()
