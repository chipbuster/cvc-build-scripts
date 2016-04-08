#!/usr/bin/env bash

## These are the OS settings for Scientific Linux 6

echo "Using settings for Atom (Scientific Linux 6)"

export BUILD_OS=sl6
export BUILD_HOST=atom

# Modules must be listed in the order they are to be loaded
export HOST_MODLIST=("sl6" "gcc/4.8" "cmake/2.8.9")

# Where should projects be downloaded/built?
export WORK_DIR=/workspace/svn_software

# Atom has 8 logical cores
export NPES=8

# Atom used QT3 (sl6)
export QT_VERSION=3

# Email error logs to this email address
# MAIL_ERR_TO=example@user.com
