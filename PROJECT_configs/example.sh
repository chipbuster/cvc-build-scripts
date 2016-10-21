#!/usr/bin/env bash

## (1) This is an example configuration for a new project. Use it as a
##     template for creating new scripts.

## (2) You cannot use undefined variables. If you want to append to a
##     potentially undefined variable, use VAR=stuff:${VAR=""}. This
##     will expand $VAR if it exists and use an empty string otherwise.

## (3) Mandatory variables are required by the build system. Try not
##     to use spaces in them--those haven't really been tested

# The name of the project
export PROJ_NAME="My_Project"
# The SVN URL to checkout to get the code
export SVN_URL=https://svn.ices.utexas.edu/repos/cvc/My_Project

## (4) Additional variables that might be useful for the duration of the build.
##     Here I define BUILD_TYPE for easy configuration, but since "Release"
##     is almost always what you want, it's mostly just for show.

export BUILD_TYPE=Release 
export MY_MESSAGE="All Done! :)"

function build_project()
{
  # The build framework will set up a lot of stuff for us. This function is
  # used to do the actual building. By the time it is called, the following
  # things will have been done by the build framework:
    
  # We will have a clean $SRC_DIR where the sources are stored
  # We will be inside the build directory $BUILD_DIR (i.e. `pwd` == $BUILD_DIR)
  # We will have a $LOG_FILE where we should store our build output

  # This project needs Fortran. On the OSX systems, this is how to set it up
  # See (3) for an explanation of the syntax at the end
  export LIBRARY_PATH=/usr/local/gfortran/lib:${LIBRARY_PATH=""}

  # We are in $BUILD_DIR, so run cmake on the $SRC_DIR with the options we want
  cmake "$SRC_DIR" -DCMAKE_BUILD_TYPE="$BUILD_TYPE" -DPRE_BUILD=ON
  make --jobs="$NPES"

  # We may have special Qt variables. If these are set, use them. Otherwise,
  # build with defaults.
  if [ -n "${QMAKE_EXECUTABLE:-}" ] && [ -n "${QT_GH_FILE:-}" ]; then
    cmake "$SRC_DIR" -DPRE_BUILD=OFF -DQT_QMAKE_EXECUTABLE="$QMAKE_EXECUTABLE"
    cmake "$SRC_DIR" -DQT4_QGLOBAL_H_FILE="$QT_GH_FILE" -DDESIRED_QT_VERSION="${QT_VERSION-4}"
  else
    cmake "$SRC_DIR" -DPRE_BUILD=OFF -DDESIRED_QT_VERSION="${QT_VERSION-4}"
  fi

  make --jobs="$NPES"
}
