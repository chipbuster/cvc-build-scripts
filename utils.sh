#!/usr/bin/env bash

function raise_alert()
{
  ATTACHMENT="$2"

  SUBJECT="Build Failure on $BUILD_HOST for project $PROJ_NAME at $(date)"
  MESSAGE="The build for $PROJ_NAME has failed on host $BUILD_HOST."

  if [ "$BUILD_OS" = "osx" ]; then
    echo $MESSAGE | mail -s $SUBJECT $ALERT_TO
  else
    echo $MESSAGE | mail -s $SUBJECT -a $ATTACHMENT $ALERT_TO
  fi

  #Hardcoded into driver, but whatever. Used to let top know if we logged
  #this error or not.
  echo "Logged error" >> /tmp/errlogged.txt
}


# Bash dynamic scoping ensures that we have all the envars that were
#available to the build_project function.
function handle_build_error()
{
  

}
