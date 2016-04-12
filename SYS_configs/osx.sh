#!/usr/bin/env bash

## These are the OS settings for OS X

echo "WARNING: You should not use these settings directly! If the build fails,
      you will not know which host it came from! Intead, copy this to a new
      config and make sure to change the BUILD_HOST to a hostname."

export BUILD_OS=OSX
export BUILD_HOST=OSX

# Modules must be listed in the order they are to be loaded
export HOST_MODLIST=()

# Where should projects be downloaded/built?
export WORK_DIR=/workspace/svn_software

# Email error logs to this email address
# MAIL_ERR_TO=example@user.com

# Make sure OS X knows where to find FORTRAN libs
export LIBRARY_PATH=/usr/local/gfortran/lib:$LIBRARY_PATH

# OS X will not give us a sane default path in cron. Set it manually
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin
