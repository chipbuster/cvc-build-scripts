#!/usr/bin/env bash

## These are the OS settings for Scientific Linux 6

echo "Using settings for Neuron (SciLinux 6)"

BUILD_OS=sl6
BUILD_HOST=sl6

# Modules must be listed in the order they are to be loaded
HOST_MODLIST=("sl6" "gcc/4.8" "cmake/2.8.9")

# Where should projects be downloaded/built?
WORK_DIR=/tmp

#Neuron has 4 cores :(
export NPES=4


# Email error logs to this email address
# MAIL_ERR_TO=example@user.com
