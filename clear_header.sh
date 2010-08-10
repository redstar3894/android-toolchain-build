#!/bin/bash
#
# clear_header.sh
#
# This script removes the installed header files from include-fix direcotry,
# if these headers files have been defined in Android. 

usage ()
{
  echo "Usage: $0 --prefix=<toolchain prefix> --sysroot=<Android sysroot> [--force]"
  echo "  <toolchain prefix>: the prefix path when you configure the install"
  echo "                      the toolchain."
  echo "   <Android sysroot>: the sysroot directory that is extracted from "
  echo "                      an Android tree."
  echo "             <force>: if specified, the headers found by this script "
  echo "                      will be deleted without confirmation."
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

force=0
PREFIX=""
SYSROOT=""

for option in $@; do
  optarg=$(expr "x$option" : 'x[^=]*=\(.*\)')

  case "$option" in
    --prefix=*)
      PREFIX=${optarg}
      if [[ ! -d ${PREFIX}/lib/gcc/arm-eabi ]]; then
        if [[ ! -d ${PREFIX}/lib/gcc/arm-linux-androideabi ]]; then
          echo "Error: ${PREFIX} is not a correct toolchain prefix path!"
          usage
          exit 1
        else
          build_target="arm-linux-androideabi"
        fi
      else
        build_target="arm-eabi"
      fi
      ;;
    --sysroot=*)
      SYSROOT=${optarg}
      ;;
    --force)
      force=1
      ;;
    *)
      echo "Error: unknown options ${option}"
      usage
      exit 1
      ;;
  esac
done

if [[ "x${PREFIX}" = "x" ]]; then
  echo "Error: you must specify the toolchain prefix path."
  usage
  exit 1
fi

if [[ "x${SYSROOT}" = "x" ]]; then
  SYSROOT="/home/jingyu/projects/gcc/toolchain_build/cupcake_rel_root2"
  echo "Warning: SYSROOT can't be empty. Set SYSROOT=${SYSROOT}."
fi

INCLUDE_ROOT=$SYSROOT/usr/include
if [[ ! -d ${INCLUDE_ROOT} ]]; then
  echo "Error: ${SYSROOT} is not a correct Android sysroot path!"
  usage
  exit 1
fi

installed_headers=`find ${PREFIX}/lib/gcc/${build_target}/*/include-fixed -name "*\.h"`

for one_header in ${installed_headers}; do
  header_name=${one_header##*/}
  defined_headers=`find ${INCLUDE_ROOT} -name ${header_name}`

  # If the installed header file has been defined in android sysroot,
  # we need to remove the installed file.
  if [[ -n ${defined_headers} ]]; then
    echo -n "Delete ${one_header}?(Y/N):"
    if [[ ${force} = 0 ]]; then
      read text
    else
      text="Y"
    fi
    if [[ "${text}" = "Y" || "${text}" = "y" ]]; then
      rm -f ${one_header}
      echo "... Removed!"
    fi
  fi
done
