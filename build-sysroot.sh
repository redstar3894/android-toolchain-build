#!/bin/sh
#
# build-sysroot.sh
#
# collect files from an Android tree to assemble a sysroot suitable for
# building a standable toolchain.
#

PRODUCT_DIR=$1
SYSROOT=$2
LIB_ROOT=$SYSROOT/usr/lib
INCLUDE_ROOT=$SYSROOT/usr/include

install_file ()
{
    mkdir -p $2/`dirname $1`
    cp -fp $1 $2/$1
}

install_helper ()
{
  (cd $1 && find . -type f | while read ff; do install_file $ff $2; done)
}

TOP=$1/../../../..

# CRT objects that need to be copied
CRT_OBJS_DIR=$PRODUCT_DIR/obj/lib
CRT_OBJS="$CRT_OBJS_DIR/crtbegin_static.o \
$CRT_OBJS_DIR/crtbegin_dynamic.o \
$CRT_OBJS_DIR/crtend_android.o"

# static libraries that need to be copied.
STATIC_LIBS_DIR=$PRODUCT_DIR/obj/STATIC_LIBRARIES
STATIC_LIBS="$STATIC_LIBS_DIR/libc_intermediates/libc.a \
$STATIC_LIBS_DIR/libm_intermediates/libm.a \
$STATIC_LIBS_DIR/libstdc++_intermediates/libstdc++.a
$STATIC_LIBS_DIR/libthread_db_intermediates/libthread_db.a"

# dynamic libraries that need to be copied.
DYNAMIC_LIBS_DIR=$PRODUCT_DIR/symbols/system/lib
DYNAMIC_LIBS="$DYNAMIC_LIBS_DIR/libdl.so \
$DYNAMIC_LIBS_DIR/libc.so \
$DYNAMIC_LIBS_DIR/libm.so \
$DYNAMIC_LIBS_DIR/libstdc++.so \
$DYNAMIC_LIBS_DIR/libthread_db.so"

# Copy all CRT objects and librarires
rm -rf $LIB_ROOT
mkdir -p $LIB_ROOT
cp -f $CRT_OBJS $STATIC_LIBS $DYNAMIC_LIBS $LIB_ROOT

# Copy headers.  This need to be done in the reverse order of inclusion
# in case there are different headers with the same name.
INCLUDE_ROOT=$SYSROOT/usr/include
rm -rf $INCLUDE_ROOT

# Check $TOP/bioinc to see if this is new lay-out in cupcake.
if [ -d $TOP/bionic ] ;then
  BIONIC_ROOT=$TOP/bionic
  LIBC_ROOT=$BIONIC_ROOT/libc
else
  BIONIC_ROOT=$TOP/system
  LIBC_ROOT=$BIONIC_ROOT/bionic
fi

install_helper $BIONIC_ROOT/libthread_db/include  $INCLUDE_ROOT
# for libm, just copy math.h and fenv.h
install $BIONIC_ROOT/libm/include/math.h $INCLUDE_ROOT
install $BIONIC_ROOT/libm/include/arm/fenv.h $INCLUDE_ROOT
install_helper $LIBC_ROOT/kernel/arch-arm $INCLUDE_ROOT
install_helper $LIBC_ROOT/kernel/common $INCLUDE_ROOT
install_helper $BIONIC_ROOT/libstdc++/include  $INCLUDE_ROOT
install_helper $LIBC_ROOT/include $INCLUDE_ROOT
install_helper $LIBC_ROOT/arch-arm/include $INCLUDE_ROOT
