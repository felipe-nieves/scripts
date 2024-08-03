#!/bin/bash
set -e

reqSpace=850000000 #850GB
#reqSpace=500000000 #500GB
SPACE=`find "$HOME/files" -user oz1r69tk -print0 | du --files0-from=- -ck | awk '/total$/ {print $1}'`
if [[ $SPACE -ge reqSpace ]]
then
  #echo "not enough space"
  #echo "free $SPACE"
  exit 1
fi
#echo "got space"
#echo "free $SPACE"
exit 0