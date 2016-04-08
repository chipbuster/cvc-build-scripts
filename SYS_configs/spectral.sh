#!/usr/bin/env bash

## These are the OS settings for OS X

echo "Using settings for Spectral (OS X 10.11)"

export BUILD_OS=osx
export BUILD_HOST=spectral

# Modules must be listed in the order they are to be loaded
export HOST_MODLIST=()

# Where should projects be downloaded/built?
export WORK_DIR=/workspace/svn_software

# Spectral has 4 available cores
export NPES=8

# Email error logs to this email address
# MAIL_ERR_TO=example@user.com

# Make sure OS X knows where to find FORTRAN libs
export LIBRARY_PATH=/usr/local/gfortran/lib:$LIBRARY_PATH

# Export the QT paths for OS X
export QMAKE_EXECUTABLE="/workspace/shared_libs/qt/bin/qmake"
export QT_GH_FILE="/workspace/shared_libs/qt/include/Qt/qglobal.h"
