#!/usr/bin/env bash

if [ ! -n "$1" ]; then
  echo "Usage: $0 <install-path>"
  echo "Installs the testing script framework to <install-path>/icesbuildscr"
  exit 1
fi

IPATH="$1" #Install path

#
echo "test" > $IPATH/test.txt

if [ $? -ne 0 ]; then
  echo "We were unable to write a test file to the specified install path"
  echo "Are you sure you have permissions to write there?"
  exit 2
fi

IFOLDER=$IPATH/icesbuildscr
mkdir $IFOLDER

cp -r PROJECT_configs $IFOLDER/PROJECT_configs
cp -r SYS_configs $IFOLDER/SYS_configs

OTHERFILES=(configs.sh utils.sh run_build_test.sh)

for file in "${OTHERFILES[@]}"; do
  cp $file $IFOLDER
done

if [ "$(uname)" = "Linux" ]; then
  sed -i s;##INSTALLPATH##;$IFOLDER;g $IFOLDER/run_build_test.sh
elif [ "$(uname)" = "Darwin" ]; then
  # I really hope this is the OS X sed or you have nobody to blame but yourself
  /usr/bin/sed -i '' s;##INSTALLPATH##;$IFOLDER;g $IFOLDER/run_build_test.sh
else
  echo "We cannot determine your os through uname."
  echo "Please manually edit the following file: $INAME"
  echo "And replace ##INSTALLPATH## with $IFOLDER"
fi
