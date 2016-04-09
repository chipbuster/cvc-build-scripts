#!/usr/bin/env bash

# Who to contact if you want to whine
export MAINTAINER="ksong@ices.utexas.edu"

## This script is at the heart of the build system. It reads configuration
# options from config.sh and sources the appropriate config scripts
# to build the specified projects.

# Note that this script will not send notifications if it fails outside of the
# project builds, so it is best to run this from another script.

set -o errexit #Exit on error
set -o nounset #Exit if undef. variable is used
set -o xtrace #Trace all instructions in the build for debugging

# This is not 100% safe to get the parent dir of the script
# but it seems to work on all ICES systems
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR

source configs.sh #Things to build and which host to use
source utils.sh

### Set up configuration for building on this particular host

TARGET_SYS_CONFIG=SYS_configs/"$I_AM".sh

set +o nounset #Need to allow for unset varibles (like LIBRARY_PATH)
source $TARGET_SYS_CONFIG     #Source the host configuration files
set -o nounset

# If needed, load modules. This is not needed if on OSX or modlist is empty
if [ "$BUILD_OS" = "OSX" ] || [ ${#HOST_MODLIST[@]} = 0 ]; then
  : #No-op. No modules need to be loaded for this host
else
  module load "${HOST_MODLIST[@]}"
fi

# If we haven't set a processor count in host config, try to find default value
# If can't find, use 1 (this is slooooooooow)
if [ ! -n "${NPES:-}" ]; then
  if [ "$(uname)" = "Linux" ]; then
    NPES=$(nproc)
  elif [ "$(uname)" = "Darwin" ]; then
    NPES=$(sysctl -n hw.ncpu)
  else
    NPES=1
  fi
fi

# If the work directory does not exist, create it
if [ ! -d "$WORK_DIR" ]; then
    rm -f "$WORK_DIR"
    mkdir -p "$WORK_DIR"
fi

# At this point, we have done all the preconfiguration needed to ensure
# a sane build environment. If something fails from now on, we assume it
# is an issue with the build. We keep nounset on, because rm on undefined
# variables is potentially catastrophic, but we allow errors to occur.
set +o errexit

# Will be changed in handle_build_error function if error occurs
export BUILD_FAILED=FALSE

# Loop over the build targets, building each one in turn
for TARGET in "${BUILD_TARGETS[@]}"; do
  cd $WORK_DIR #Get back into the main work directory

  #Source the script for our current build target
  source $SCRIPT_DIR/PROJECT_configs/${TARGET}.sh

  # Load project modules, if any (the ="" syntax provides a default empty string)
  # so that we don't trigger the undefined variable checker
  if [ -n "${PROJ_MODLIST-""}" ] && [ ! "$BUILD_OS" = "OSX" ]; then
    module load "${PROJ_MODLIST[@]}"
  fi

  # Removing the project directory can take time (esp. for large builds)
  # Speed this up by renaming it so we can remove it in the background
  if [ -e $PROJ_NAME ]; then
    mv $PROJ_NAME "${PROJ_NAME}_old_$(date +%m%d)"
    rm -rf "${PROJ_NAME}_old_$(date +%m%d)" &
  fi

  # Do the same for the old build directory
  if [ -e ${PROJ_NAME}_build ]; then
    mv ${PROJ_NAME}_build "${PROJ_NAME}_buildold_$(date +%m%d)"
    rm -rf "${PROJ_NAME}_buildold_$(date +%m%d)" &
  fi

  # Define important directories and files. These 3 MUST be defined for
  # the project build scripts to work.
  BUILD_DIR="$WORK_DIR/${PROJ_NAME}_build"
  SRC_DIR="$WORK_DIR/$PROJ_NAME"
  LOG_FILE="$BUILD_DIR/${PROJ_NAME}.out"

  #Check out the SVN repo with the cvcsvn user
  svn co --username cvcsvn $SVN_URL $SRC_DIR &> /dev/null
  mkdir $BUILD_DIR
  cd $BUILD_DIR

  # Open the logfile with info about the build
  build_info_dump  #Defined in utils.sh

  # Build the project and send output to the logfile.

  trap "export RETRY_BUILD=TRUE" ERR #If an error occurs, trap it and set retry
  build_project >> $LOG_FILE 2>&1

  if [ "${RETRY_BUILD-FALSE}" = "TRUE" ]; then #Retry the build
    echo "" > $LOG_FILE  #Clean the build file
    build_info_dump

    #Retry the build. If it fails again, handle the error.
    trap handle_build_error ERR  #Trap any errors in the build command
    build_project >> $LOG_FILE 2>&1
    trap - ERR  #turn off the trap

  fi

  # Record the build end time
  echo "Build ended at $(date)" >> $LOG_FILE

  # Before we move on to the next build, unload any modules that are project-only
  if [ -n "${PROJ_MODLIST=""}" ] && [ ! "$BUILD_OS" = "OSX" ]; then
    for MODULE in "${PROJ_MODLIST[@]}"; do
      module unload $MODULE
    done
  fi
done
