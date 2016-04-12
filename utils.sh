#!/usr/bin/env bash

# Bash dynamic scoping ensures that we have all the envars that were
# available to the build_project function. Nasty, but effective.
function handle_build_error()
{
  #Note: these settings are hardcoded for ICES machines. If you move
  #this script to a machine that does not have access to /net, you will
  #need to change this function.

  #BSD date and GNU date do not understand each other. Get important
  #dates now so that we don't have to deal with that in the future.
  TODAY=$(date +%Y-%m-%d)
  if [ "$(uname)" = "Darwin" ] || [ "$BUILD_OS" = "OSX" ]; then
    TMRRW=$(date -v+1d +%Y-%m-%d)
    DAYB4Y=$(date -v-1d +%Y-%m-%d)
  else
    TMRRW=$(date --date='tomorrow' +%Y-%m-%d)
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
  # I found this line on stackoverflow :D
  USERS=( $(svn log $SRC_DIR --revision \{$DAYB4Y\}:\{$TMRRW\} --quiet \
   | grep "^r" | awk '{print $3}' | sort | uniq | tr '\n' ' ' ) )


  # If no users found, email guardians
  if [ "${USERS[@]-"None"}" = "None" ]; then
    for GUARDIAN in "${GUARDIANS[@]}"; do
      mail -s "$SUBJECT, No culprit" "${GUARDIAN}" <<ENDMAIL

CVC BuildBot has detected a broken nightly build on
the system "$I_AM" for the project $PROJ_NAME.

BuildBot was unable to find the culprit through the SVN logs. This suggests
that a commit was made to a subproject that broke the build.

The users who have committed to any CVC SVN repo in the last two days are:

$(svn log https://svn.ices.utexas.edu/repos/cvc/ --revision \{$DAYB4Y\}:\{$TMRRW\} --quiet \
 | grep "^r" | awk '{print $3}' | sort | uniq | tr '\n' ' ' )

BuildBot has diligently recorded data about the failing build. These include
build host info, svn info, environmental data, and the output of the build
itself. The complete logs for the failed build can be accessed from any
CVC machine by going to:

$LOG_DIR/$(basename $LOG_FILE)

The commands used for the build should have been traced by bash---you can find
the literal commands (with substitution applied) in this log file prepended by
a plus sign (+). You can grep them with grep '^+'.

BuildBot's brain is made of bash, which is a fuzzy material that breaks a lot.
If you feel that this message is in error, please contact BuildBot's maintainer
at $MAINTAINER.
ENDMAIL
done

else  #IF users found, email those users

  # If users found, email all involved users
  for USER in "${USERS[@]}"; do
  mail -s "$SUBJECT" "${USER}@ices.utexas.edu" <<ENDMAIL

Hello there! This is CVC BuildBot. We have detected a broken nightly build on
the system "$I_AM" for the project $PROJ_NAME. Build Bot has detected that you
committed to this SVN project in the last two days.

Please review your recent code commits on an ICES system running $BUILD_OS.
If you find that you are not responsible for the error, please ask others
to check their commits.

The users who have committed in the last two days are:

  ${USERS[*]-"ERROR:NO USERS FOUND"}

BuildBot has diligently recorded data about the failing build. These include
build host info, svn info, environmental data, and the output of the build
itself. The complete logs for the failed build can be accessed from any
CVC machine by going to:

  $LOG_DIR/$(basename $LOG_FILE)

The commands used for the build should have been traced by bash---you can find
the literal commands (with substitution applied) in this log file prepended by
a plus sign (+). You can grep them with grep '^+'.

BuildBot's brain is made of bash, which is a fuzzy material that breaks a lot.
If you feel that this message is in error, please contact BuildBot's maintainer
at $MAINTAINER.

ENDMAIL

done

fi
}


#This function is used to dump build info before a project starts. It is a
#good tool for making sure everything is the way we think it is.
function build_info_dump(){
  echo "===This is $PROJ_NAME on $BUILD_HOST ($BUILD_OS)===" >> $LOG_FILE
  echo "Build started at $(date)" >> $LOG_FILE
  echo "Modules specified by HOST are: ${HOST_MODLIST[*]:-None}" >> $LOG_FILE
  echo "Modules specified by PROJECT are: ${PROJ_MODLIST[*]:-None}" >> $LOG_FILE
  echo "We are building with $NPES processors" >> $LOG_FILE
  echo "Here is the SVN Repository info" >> $LOG_FILE
  svn info $SRC_DIR >> $LOG_FILE
  echo "\n\n" >> $LOG_FILE
  echo "Here is the current environment:" >> $LOG_FILE
  printenv >> $LOG_FILE
  echo "===BUILD BEGINS HERE===" >> $LOG_FILE
}
