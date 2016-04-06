#!/usr/bin/env bash

## These are the OS settings for CentOS 7

echo "WARNING: You should not use these settings directly! If the build fails,
      you will not know which host it came from! Intead, copy this to a new
      config and make sure to change the BUILD_HOST to a hostname."

BUILD_OS=c7
BUILD_HOST=c7

# Modules must be listed in the order they are to be loaded
HOST_MODLIST=("c7" "gcc/5.2" "cmake/3.3.2")

# Where should projects be downloaded/built?
WORK_DIR=/tmp

# Email error logs to this email address
# MAIL_ERR_TO=example@user.com
