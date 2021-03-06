#!/usr/bin/env bash

## Mandatory variables
export PROJ_NAME=MolSurf
export SVN_URL=https://svn.ices.utexas.edu/repos/cvc/trunk/MolSurf

export BUILD_TYPE=Release

function build_project()
{
  #These tasks will have been done for us by the time this fn is called
  #We will have a clean $SRC_DIR where the sources are stored
  #We will be inside the build directory $BUILD_DIR
  #We will have a $LOG_FILE where we should store our build output

  export LIBRARY_PATH=/usr/local/gfortran/lib:${LIBRARY_PATH=""}

  cmake "$SRC_DIR" -DCMAKE_BUILD_TYPE="$BUILD_TYPE" -DPRE_BUILD=ON
  make --jobs="$NPES"

  #If these variables are set, inform cmake. Otherwise, use defaults
  if [ -n "${QMAKE_EXECUTABLE:-}" ] && [ -n "${QT_GH_FILE:-}" ]; then
    cmake "$SRC_DIR" -DPRE_BUILD=OFF -DQT_QMAKE_EXECUTABLE="$QMAKE_EXECUTABLE"
    cmake "$SRC_DIR" -DPRE_BUILD=OFF -DQT4_QGLOBAL_H_FILE="$QT_GH_FILE"
  else
    cmake "$SRC_DIR" -DPRE_BUILD=OFF
  fi
  make --jobs="$NPES"
}
