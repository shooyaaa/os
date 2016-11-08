#!/bin/bash

FTPURL='ftp://ftp.gnu.org/gnu/'
BUILDDIR='/tmp/cross_compile'
mkdir -p ${BUILDDIR}
if [ ! -d "${BUILDDIR}" ]; then
    echo 'can not mkdir '${BUILDDIR}
    exit
fi
GCCVERSION=`gcc --version|grep -o -E "\s([0-9]+\.){2,}[0-9]+\s"|tr -d " "`
echo 'gcc version is '${GCCVERSION} try to upgrade it;

sudo apt upgrade -y --force-yes -qq gcc
BINUTILSVERSION=`ld -v |grep -o -E "[0-9]*\.[0-9]*"
`
echo 'binutils version is '${BINUTILSVERSION} try to upgrade it;

sudo apt upgrade -y --force-yes -qq binutils
BINUTILSTARBALL=binutils-${BINUTILSVERSION}.tar.bz2
GCCTARBALL=gcc-${GCCVERSION}.tar.bz2
if [ ! -f "${BUILDDIR}/${BINUTILSTARBALL}" ]; then
    wget -P ${BUILDDIR} ${FTPURL}binutils/${BINUTILSTARBALL}
fi

if [ ! -f "${BUILDDIR}/${GCCTARBALL}" ]; then
    wget -P ${BUILDDIR} ${FTPURL}gcc/gcc-${GCCVERSION}/${GCCTARBALL}
fi

cd ${BUILDDIR}

GCCDIR=${BUILDDIR}/gcc-${GCCVERSION}
BINUTILSDIR=${BUILDDIR}/binutils-${BINUTILSVERSION}
if [ ! -d "${BINUTILSDIR}" ]; then
    tar -xjvf ${BINUTILSTARBALL}
fi
if [ ! -d "${GCCDIR}" ]; then
    tar -xjvf ${GCCTARBALL}
fi
if [ ! -d "${GCCDIR}/gmp/" ]; then
    cd gcc-${GCCVERSION}
    ./contrib/download_prerequisites
fi

export PREFIX="$HOME/cross_compile"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

cd ${BINUTILSDIR}
./configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install

cd ${GCCDIR}
which -- $TARGET-as || echo $TARGET-as is not in the PATH
./configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
