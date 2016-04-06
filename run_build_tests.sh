#!/usr/bin/env bash

set -e #Exit on error
set -u #Exit if variable is undefined

SCRIPT_DIR=##INSTALLPATH##
cd $SCRIPT_DIR

source configs.sh #Things to build and which host to use
source utils.sh

### Set up configuration for building on this particular host

TARGET_SYS_CONFIG=SYS_configs/"$I_AM".sh

set +u #Need to allow for unset varibles (like LIBRARY_PATH)
source $TARGET_SYS_CONFIG     #Source the host configuration files
set -u

# If needed, load modules. This is not needed if on osx or modlist is empty
if [ "$BUILD_OS" = "osx" ] || [ ${#HOST_MODLIST [@]} = 0 ]; then
  : #No-op. No modules need to be loaded for this host
else
  for MODULE in $HOST_MODLIST; do
    module load $MODULE
  done
fi

# If we haven't set a processor count in host config, default to 1
if [ -z "$NPES" ]; then
  NPES=1
fi

# Move to where the builds/checkouts should occur

  cd $WORK_DIR #Get back into the main work directory

  #Source the script for our current build target
  source $SCRIPT_DIR/PROJECT_configs/${TARGET}.sh 

  # Removing the entire directory can take time (esp. for large builds)
  # Speed this up by renaming it so we can remove it in the background
  if [ -e $PROJ_NAME ]; then
    mv $PROJ_NAME ${PROJ_NAME}_old
    rm -rf ${PROJ_NAME}_old &
  fi

  # Do the same for the old build directory
  if [ -e ${PROJ_NAME}_build ]; then
    mv ${PROJ_NAME}_build ${PROJ_NAME}_buildold
    rm -rf ${PROJ_NAME}_buildold &
  fi

  svn co $SVN_URL $PROJ_NAME
  mkdir ${PROJ_NAME}_build
  cd ${PROJ_NAME}_build
  SRC_DIR=$WORK_DIR/$PROJ_NAME

  echo "Building $PROJ_NAME"

  build_project || raise_alert $GUARDIAN $WORK_DIR/$PROJ_NAME

  cd $WORK_DIR
done
