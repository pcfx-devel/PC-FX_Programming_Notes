#!/bin/sh
#

TOPDIR=$(pwd)
echo TOPDIR is $TOPDIR

#---------------------------------------------------------------------------------
# set the target and compiler flags
#---------------------------------------------------------------------------------

# Building the toolchain to compile for the NEC V810 cpu.

TARGET=v810

#---------------------------------------------------------------------------------
# Setup the toolchain for linux
#
# ***********************************************************************
# *** NOTE: Validate that these are the correct fdirectories for your ***
# ***       environment and update them if needed !!                  ***
# ***********************************************************************
#
#---------------------------------------------------------------------------------

export V810GCC=$TOPDIR/pcfx/bin/v810-gcc

export PATH=$TOPDIR/pcfx/bin:$V810GCC/bin:$PATH

# This is the location of where the pcfxtools repository has been placed on the local machine
export SRCDIR=$TOPDIR/pcfxtools

# This is location of where the binaries will be installed; it should be in your PATH during PCFX executable builds
export DSTDIR=$TOPDIR/pcfx/bin

#---------------------------------------------------------------------------------
# Build and install pcfxtools
#---------------------------------------------------------------------------------


mkdir -p $DSTDIR

cd $SRCDIR

# pcfxtools builds in the source tree ... better try to clean it.

make clean

#

make 2>&1 | tee ../pcfxtools_make.log

if [ $? != 0 ]; then
  echo "Error: building pcfxtools";
  exit 1;
fi

make install 2>&1 | tee ../pcfxtools_install.log


echo
echo "$0 finished, don't forget to check for any error messages."

exit 0;
