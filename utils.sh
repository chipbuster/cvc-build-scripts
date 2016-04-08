#!/usr/bin/env bash

function message_guardians()
{
  ATTACHMENT="$2"

  SUBJECT="Build Failure on $BUILD_HOST for project $PROJ_NAME at $(date)"
  MESSAGE="The build for $PROJ_NAME has failed on host $BUILD_HOST."

  if [ "$BUILD_OS" = "OSX" ]; then
    echo $MESSAGE | mail -s $SUBJECT $ALERT_TO
  else
    echo $MESSAGE | mail -s $SUBJECT -a $ATTACHMENT $ALERT_TO
  fi

  #Hardcoded into driver, but whatever. Used to let top know if we logged
  #this error or not.
  echo "Logged error" >> /tmp/errlogged.txt
}


# Bash dynamic scoping ensures that we have all the envars that were
# available to the build_project function. Nasty, but effective.
function handle_build_error()
{
  #Note: these settings are hardcoded for ICES machines. If you move
  #this script to a machine that does not have access to /net, you will
  #need to change this function.

  #Today's date and two days ago's date
  TODAY=$(date +%Y-%m-%d)
  if [ "$(uname)" = "Darwin" ] || [ "$BUILD_OS" = "OSX" ]; then
    DAYB4Y=$(date -v-1d +%Y-%m-%d)
  else
    DAYB4Y=$(date --date='2 days ago' +%Y-%m-%d)
  fi

  # If the appropriate directory does not exist, create it.
  # Logs will be stored on neuron, labeled by date and system id (I_AM)
  LOG_DIR="/net/neuron/workspace/buildlogs/$TODAY/$I_AM"

  if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
  fi

  #Move the log file to the log directory
  cp $LOG_FILE $LOG_DIR &

  #Get a list of all users that have commits in the last two days
  REVNUM=$(svn info $SRC_DIR | grep -i 'Revision' | awk '{print $2}')
  SUBJECT="[CVC BB]: Failure to build ${PROJ_NAME}(r${REVNUM-SVNERR}) on $I_AM"
  USERS=( $(svn log $SRC_DIR --revision \{$DAYB4Y\}:\{$TODAY\} --quiet \
   | grep "^r" | awk '{print $3}' | sort | uniq | tr '\n' ' ' ) )

  # Email every user that's involved
  mail -s "$SUBJECT" chipbuster@gmail.com <<ENDMAIL

Hello there! This is CVC BuildBot. We have detected a broken nightly build on
the system \"$I_AM\" for the project $PROJ_NAME. Build Bot has detected that you
committed to this SVN project in the last two days.

Please review your recent code commits on an ICES system running $BUILD_OS.
If you find that you are not responsible for the error, please ask others
to check their commits.

The users who have committed in the last two days are:

  ${USERS[*]-"None"}

BuildBot has diligently recorded data about the failing build. These include
build host info, svn info, environmental data, and the output of the build
itself. The complete logs for the failed build can be accessed from any
CVC machine by going to:

  $LOG_DIR/$(basename $LOG_FILE)

BuildBot's brain is made of bash, which is a fuzzy material that breaks a lot.
If you feel that this message is in error, please contact BuildBot's maintainer
at $MAINTAINER.

ENDMAIL


}
