#! /usr/bin/env bash

set -e # Fail on error
umask 022 # Give group permissions the same as user

# Number of cores is default 1, but more can be specified
NPROC=${1-1}
BUILD_TYPE=Release
WORK_DIR=/Volumes/Workspace/software-fresh

# Need to be in the correct location, not the alias. Important for petsc
cd $WORK_DIR

# Delete the previous version and download a new one.
ROOT_FOLDER=MolSurf
rm -rf "./$ROOT_FOLDER"

svn co https://svn.ices.utexas.edu/repos/cvc/trunk/$ROOT_FOLDER

cd $ROOT_FOLDER
mkdir $BUILD_TYPE
cd $BUILD_TYPE

# Export library
export LIBRARY_PATH=/usr/local/gfortran/lib:$LIBRARY_PATH
cmake ../ -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DPRE_BUILD=ON
make -j4
cmake ../ -DPRE_BUILD=OFF -DQT_QMAKE_EXECUTABLE=/workspace/shared_libs/qt/bin/qmake
cmake ../ -DPRE_BUILD=OFF -DQT4_QGLOBAL_H_FILE=/workspace/shared_libs/qt/include/Qt/qglobal.h
cmake ../ -DPRE_BUILD=OFF
make -j4

echo
echo "Finished Successfully!!"
echo
