#!/usr/bin/env bash

## These are the OS settings for CentOS 7

echo "Using settings for Thalamus (CentOS 7)"

BUILD_OS=c7
BUILD_HOST=thalamus

# Modules must be listed in the order they are to be loaded
HOST_MODLIST=("c7" "gcc/5.2" "cmake/3.3.2")

# Where should projects be downloaded/built?
WORK_DIR=/tmp

#Thalamus has 16 processing entities
export NPES=16

# Email error logs to this email address
# MAIL_ERR_TO=example@user.com
