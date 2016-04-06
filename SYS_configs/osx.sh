#!/usr/bin/env bash

## These are the OS settings for OS X

echo "WARNING: You should not use these settings directly! If the build fails,
      you will not know which host it came from! Intead, copy this to a new
      config and make sure to change the BUILD_HOST to a hostname."

BUILD_OS=osx
BUILD_HOST=osx

# Modules must be listed in the order they are to be loaded
HOST_MODLIST=()

# Where should projects be downloaded/built?
WORKDIR=/tmp

# Email error logs to this email address
# MAIL_ERR_TO=example@user.com

# Make sure OS X knows where to find FORTRAN libs
export LIBRARY_PATH=/usr/local/gfortran/lib:$LIBRARY_PATH
