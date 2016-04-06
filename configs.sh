#!/bin/bash

# This should be a script name in SYS_configs: if I_AM=derp, then the hostconfig
# SYS_configs/derp.sh should exist.
export I_AM=spectral

# Each element of this array should correspond to a script in PROJECT_configs
# If "proj_derp" is in the array, then PROJECT_configs/proj_derp.sh should exist
export BUILD_TARGETS=("molsurf" "texmol" "volrover")

# Who should we alert when the build explodes?
export GUARDIAN=kcsong+crontab@utexas.edu
