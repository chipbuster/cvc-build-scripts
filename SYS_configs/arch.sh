#!/usr/bin/env bash

## These are the OS settings for Scientific Linux 6

echo "Using settings for Arch Linux"

export BUILD_OS=arch
export BUILD_HOST=arch

# Modules must be listed in the order they are to be loaded
export HOST_MODLIST=()

# Where should projects be downloaded/built?
export WORK_DIR=/tmp

#Neuron has 4 cores :(
export NPES
NPES=$(nproc)

export QT_SELECT=4

# Email error logs to this email address
# MAIL_ERR_TO=example@user.com
