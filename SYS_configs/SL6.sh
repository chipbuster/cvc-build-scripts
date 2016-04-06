#!/usr/bin/env bash

## These are the OS settings for Scientific Linux 6

echo "WARNING: You should not use these settings directly! If the build fails,
      you will not know which host it came from! Intead, copy this to a new
      config and make sure to change the BUILD_HOST to a hostname."

BUILD_OS=sl6
BUILD_HOST=sl6

# Modules must be listed in the order they are to be loaded
HOST_MODLIST=("sl6" "gcc/4.8" "cmake/2.8.9")

# Where should projects be downloaded/built?
WORK_DIR=/tmp

# Email error logs to this email address
# MAIL_ERR_TO=example@user.com
