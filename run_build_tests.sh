#!/bin/bash

set -e #Exit on error
set -u #Exit if variable is undefined

source configs.sh #Things to build and which host to use
source utils.sh

### Set up configuration for building on this particular host

TARGET_SYS_CONFIG="$I_AM".sh
source $TARGET_SYS_CONFIG     #Source the host configuration files

# If needed, load modules. This is not needed if on osx or modlist is empty
if [ "$BUILD_OS" = "osx" ] || [ ${#HOST_MODLIST [@]} = 0 ]; then
  : #No-op. No modules need to be loaded for this host
else
  for MODULE in $HOST_MODLIST; do
    module load $MODULE
  done
fi

# Move to where the builds/checkouts should occur

cd $WORKDIR

#
