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

# This is the location of where the liberis repository has been placed on the local machine
export SRCDIR=$TOPDIR/liberis

# This is location of where the libraries will be installed; it should be in your PATH during PCFX executable builds
export DSTDIR=$TOPDIR/liberis


#---------------------------------------------------------------------------------
# Build and install liberis
#---------------------------------------------------------------------------------


cd $SRCDIR

# liberis builds in the source tree ... better try to clean it.

make clean
make examples clean

#

make 2>&1 | tee ../liberis_make.log

if [ $? != 0 ]; then
  echo "Error: building liberis";
  exit 1;
fi

make install 2>&1 | tee ../liberis_install.log

if [ $? != 0 ]; then
  echo "Error: installing liberis";
  exit 1;
fi

make examples 2>&1 | tee ../liberis_examples.log

if [ $? != 0 ]; then
  echo "Error: building liberis examples";
  exit 1;
fi

make -j 1 example_cds 2>&1 | tee ../liberis_example_cds.log

if [ $? != 0 ]; then
  echo "Error: building liberis example cds";
  exit 1;
fi

cd ../../

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0;
