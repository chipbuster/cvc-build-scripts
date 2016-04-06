#!/usr/bin/env bash

set -o errexit #Exit on error
set -o nounset #Exit if undef. variable is used
set -o pipefail #Exit if a command in a pipe fails

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

# At this point, we have done all the preconfiguration needed to ensure
# a sane build environment. If something fails from now on, we assume it
# is an issue with the build. We keep nounset on, because rm on undefined
# variables is potentially catastrophic, but we allow errors to occur.
set +o errexit

# Move to where the builds/checkouts should occur

for TARGET in $BUILD_TARGETS; do
  cd $WORK_DIR #Get back into the main work directory

  #Source the script for our current build target
  source $SCRIPT_DIR/PROJECT_configs/${TARGET}.sh

  # Load project modules, if any
  if [ -n $PROJ_MODLIST ]; then
    for MODULE in $PROJ_MODLIST; do
      module load $PROJ_MODLIST
    done
  fi

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

  # Define important directories and files
  BUILD_DIR="$WORK_DIR/${PROJ_NAME}_build"
  SRC_DIR="$WORK_DIR/$PROJ_NAME"
  LOG_FILE="$BUILD_DIR/${PROJ_NAME}.out"

  svn co $SVN_URL $SRC_DIR &> /dev/null #We don't need to see the SVN co
  mkdir $BUILD_DIR
  cd $BUILD_DIR

  # Open the logfile with info about the build
  echo "===This is $PROJ_NAME on $BUILD_HOST ($BUILD_OS)===" >> $LOG_FILE
  echo "Modules loaded by HOST are:  ${HOST_MODLIST:-None}" >> $LOG_FILE
  echo "Modules loaded by PROJECT are:  ${PROJ_MODLIST:-None}" >> $LOG_FILE
  echo "We are building with $NPES processors" >> $LOG_FILE
  echo "Here is the SVN Repository info" >> $LOG_FILE
  svn info $SRC_DIR >> $LOG_FILE
  echo "\n\n" >> $LOG_FILE
  echo "Here is the current environment:" >> $LOG_FILE
  export >> $LOG_FILE
  echo "===BUILD BEGINS HERE===" >> $LOG_FILE

  # Build the project and send output to the logfile.
  build_project >> $LOG_FILE 2>&1

  # Before we move on to the next build, unload any modules that are project-only
  if [ -n $PROJ_MODLIST ]; then
    for MODULE in $PROJ_MODLIST; do
      module unload $PROJ_MODLIST
    done
  fi

  # || raise_alert $GUARDIANS $WORK_DIR/$PROJ_NAME  #Guardians are temporarily offline
done
