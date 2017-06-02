#!/usr/bin/env bash

## Mandatory variables
export PROJ_NAME=VolUtils
export SVN_URL=https://svn.ices.utexas.edu/repos/cvc/trunk/VolUtils-cmake

export BUILD_TYPE=Release

function build_project()
{
  #These tasks will have been done for us by the time this fn is called
  #We will have a clean $SRC_DIR where the sources are stored
  #We will be inside the build directory $BUILD_DIR
  #We will have a $LOG_FILE where we should store our build output

  export LIBRARY_PATH=/usr/local/gfortran/lib:${LIBRARY_PATH=""}

  cmake "$SRC_DIR" -DPRE_BUILD=ON
  make clean && make --jobs="$NPES"

  cmake "$SRC_DIR" -DPRE_BUILD=OFF
  make --jobs="$NPES"
}
