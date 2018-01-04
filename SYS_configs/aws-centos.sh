#!/usr/bin/env bash

## These are the OS settings for CentOS 7

export BUILD_OS=CentOS7
export BUILD_HOST=aws

# Modules must be listed in the order they are to be loaded
export HOST_MODLIST=()

# Where should projects be downloaded/built?
export WORK_DIR=/home/centos/svnbuild

# Email error logs to this email address
# MAIL_ERR_TO=example@user.com
