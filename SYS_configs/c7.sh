#!/bin/bash

## These are the OS settings for CentOS 7

echo "Using settings for CentOS 7."

BUILD_OS=c7
BUILD_HOST=c7

# Modules must be listed in the order they are to be loaded
HOST_MODLIST=("c7" "gcc/5.2" "cmake/3.3.2") 

# Where should projects be downloaded/built?
WORKDIR=/tmp

# Email error logs to this email address
# MAIL_ERR_TO=example@user.com
