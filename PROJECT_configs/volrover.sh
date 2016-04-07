#!/usr/bin/env bash

## Mandatory variables
export PROJ_NAME=VolumeRover
export SVN_URL=https://svn.ices.utexas.edu/repos/cvc/trunk/VolumeRover-Qt4

export BUILD_TYPE=Release

function build_project()
{
  #These tasks will have been done for us by the time this fn is called
  #We will have a clean $SRC_DIR where the sources are stored
  #We will be inside the build directory $BUILD_DIR
  #We will have a $LOG_FILE where we should store our build output

  export LIBRARY_PATH=/usr/local/gfortran/lib:${LIBRARY_PATH=""}

  cmake $SRC_DIR -DPRE_BUILD=ON
  make clean && make --jobs=$NPES

  #If the host config specifies these variables, QT should be appropriately set
  if [ -n "${QMAKE_EXECUTABLE=""}" ] && [ -n "${QT_GH_FILE=""}" ]; then
    cmake $SRC_DIR -DPRE_BUILD=OFF -DQT4_QGLOBAL_H_FILE=$QT_GH_FILE -DQT_QMAKE_EXECUTABLE=$QMAKE_EXECUTABLE -DDESIRED_QT_VERSION=4
  else
    cmake $SRC_DIR -DPRE_BUILD=OFF -DDESIRED_QT_VERSION=4
  fi

  cmake $SRC_DIR -DBUILD_QSLIM=ON -DBUILD_SURFACEMESHDECOMPOSITION=ON -DBUILD_SWEETMESH_LIB=ON -DBUILD_TILING_LIB=ON -DBUILD_VOLUMEROVER_2=ON -DBUILD_VOLUTILS=ON -DBUILD_MMHLS_LIB=ON -DBUILD_HLEVELSET_LIB=ON -DBUILD_SUPERSECONDARYSTRUCTURES_LIB=ON
  cmake $SRC_DIR -DBUILD_VOLUMEROVER_NEURON=ON -DBUILD_S3_MAIN=ON

  make VolumeRover2 --jobs=$NPES

  make --jobs=$NPES
}
