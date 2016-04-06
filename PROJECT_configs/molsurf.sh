#!/bin/bash

## Mandatory variables
export PROJ_NAME=MolSurf
export SVN_URL=https://svn.ices.utexas.edu/repos/cvc/trunk/MolSurf

export BUILD_TYPE=Release

LOG_FILE=$PROJ_NAME.out

function build_project()
{
  #These tasks will have been done for us by the time this fn is called
  #cd $WORK_DIR
  #rm -rf $PROJ_NAME
  #svn co $SVN_URL $PROJ_NAME
  #mkdir ${PROJ_NAME}_build
  #cd ${PROJ_NAME}_build

  export LIBRARY_PATH=/usr/local/gfortran/lib:$LIBRARY_PATH

  cmake ../ -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DPRE_BUILD=ON | tee $LOG_FILE
  make | tee -a $LOG_FILE

  #OS X does not have QT in its PATHS, so we need to specify them
  if [ "$BUILD_HOST" = "spectral" ]; then
    cmake ../ -DPRE_BUILD=OFF -DQT_QMAKE_EXECUTABLE=$QMAKE_EXECUTABLE | tee -a $LOG_FILE
    cmake ../ -DPRE_BUILD=OFF -DQT4_QGLOBAL_H_FILE=$QT_GH_FILE | tee -a $LOG_FILE
  else
    cmake ../ -DPRE_BUILD=OFF | tee -a $LOG_FILE
  fi
  make | tee -a $LOG_FILE
}
