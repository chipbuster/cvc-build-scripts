#! /bin/bash -e
# Fail on error
set -e
# Give group permissions the same as user
umask 022

# Can add a flag that specifies the number of cores to compile with
NPROC=${1-1}

# Need to be in the correct location, not the alias. Important for petsc
cd /Volumes/Workspace/software-fresh

ROOT_FOLDER=VolumeRover-Qt4

# The build type and directory (either Release or Debug)
BUILD_TYPE=Release
BUILD_DIR=${BUILD_TYPE}

# Clean up last build
rm -rf $ROOT_FOLDER

# Checkout from repo
svn co https://svn.ices.utexas.edu/repos/cvc/trunk/$ROOT_FOLDER

# Go to directory
cd $ROOT_FOLDER

# Export fortran library
export LIBRARY_PATH=/usr/local/gfortran/lib:$LIBRARY_PATH

echo "Creating directory $BUILD_DIR (if it doesn't already exist)"
mkdir -p $BUILD_DIR
cd $BUILD_DIR
echo "Initial cmake"
cmake ../ -DPRE_BUILD=ON
make clean && make -j $NPROC
echo "cmake with PRE_BUILD set to OFF"
cmake ../ -DPRE_BUILD=OFF -DQT4_QGLOBAL_H_FILE=/workspace/shared_libs/qt/include/Qt/qglobal.h -DQT_QMAKE_EXECUTABLE=/workspace/shared_libs/qt/bin/qmake -DDESIRED_QT_VERSION=4
echo "cmake with QT Version and Build Type set"
cmake ../ -DCMAKE_BUILD_TYPE=$BUILD_TYPE
echo "cmake with other requirements on"
cmake ../ -DBUILD_QSLIM=ON -DBUILD_SURFACEMESHDECOMPOSITION=ON -DBUILD_SWEETMESH_LIB=ON -DBUILD_TILING_LIB=ON -DBUILD_VOLUMEROVER_2=ON -DBUILD_VOLUTILS=ON -DBUILD_MMHLS_LIB=ON -DBUILD_HLEVELSET_LIB=ON -DBUILD_SUPERSECONDARYSTRUCTURES_LIB=ON
cmake ../ -DBUILD_VOLUMEROVER_NEURON=ON -DBUILD_S3_MAIN=ON
echo "Making VolumeRover2 with $NPROC cores"
make VolumeRover2 -j$NPROC
echo "Making everything with $NPROC cores"
make -j$NPROC

echo
echo "Finished Successfully!!"
echo
