#!/bin/bash
# 
# Script to download OPSEC SDK to build fw1loggrabber
#
# (c) Ulrik Holmén - NTT Com Security 2016
#
# Before building: sudo apt-get install gcc-multilib g++-multilib libelf-dev:i386

OPSEC_DOWNLOAD="http://dl3.checkpoint.com/paid/8e/8ee4831512ee5a52fb484bdc364c4d75/Check_Point_OPSECSDK_linux50_sk110425.tar.gz?HashKey=1476970892_3b806b01e0dac8bdf5e577424e664686&xtn=.gz"
OPSEC_ZIPFILE="Check_Point_OPSECSDK_linux50_sk110425.tar.gz"
URL=$(wget "http://supportcontent.checkpoint.com/file_download?id=7385" -O - | grep ".zip" | awk -F "href=" '{print $2}' | sort | uniq | sed 's/[>\s\"]//g' | cat -v | sed 's/\^M//g' )
OPSEC_DIR="OPSEC"

echo "Creating ."$TARGET" packages"

# Create the OPSEC dir for unpacking OPSEC dependencies
if [ -d $OPSEC_DIR ]; then
  echo $OPSEC_DIR " directory already created"
else
  echo "Creating $OPSEC_DIR directory"
  mkdir $OPSEC_DIR
fi

# Unpack the OPSEC package from Checkpoint
pushd $OPSEC_DIR
  if [ -f $OPSEC_ZIPFILE ]; then
    echo "OPSEC .zip archive already downloaded"
  else
	echo "Downloading: " $URL
    wget $URL -O $OPSEC_ZIPFILE
  fi

  if [ -d linux30 ]; then
    echo $OPSEC_ZIPFILE "already unpacked"
  else
    unzip $OPSEC_ZIPFILE
    for FILE in *linux30*; do tar -xvzf $FILE; done
  fi
popd
