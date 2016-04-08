#!/usr/bin/env bash

## These are the OS settings for CentOS 7

echo "Using settings for Thalamus (CentOS 7)"

export BUILD_OS=c7
export BUILD_HOST=thalamus

# Modules must be listed in the order they are to be loaded
export HOST_MODLIST=("c7" "gcc/5.2" "cmake/3.3.2")

# Where should projects be downloaded/built?
export WORK_DIR=/workspace/svn_software

#Thalamus has 16 processing entities
export NPES=16

# Email error logs to this email address
# MAIL_ERR_TO=example@user.com
