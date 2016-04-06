#!/bin/bash

function raise_alert()
{
  ALERT_TO="$1"
  ATTACHMENT="$2"

  SUBJECT="Build Failure on $BUILD_HOST for project $PROJ_NAME at $(date)"
  MESSAGE="The build for $PROJ_NAME has failed on host $BUILD_HOST."

  if [ "$BUILD_OS" = "osx" ]; then
    echo $MESSAGE | mail -s $SUBJECT $ALERT_TO
  else
    echo $MESSAGE | mail -s $SUBJECT -a $ATTACHMENT $ALERT_TO
  fi
}
