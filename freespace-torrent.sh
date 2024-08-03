#!/bin/bash
set -e

reqSpace=850000000 # 850GB
# reqSpace=500000000 # 500GB

# Default torrent size to 0 if not provided
torrentSize=0

# Parse command-line arguments for the --size option
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --size) torrentSize="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

torrentSize=$((torrentSize / 1024))

SPACE=$(find "$HOME/files" -user oz1r69tk -print0 | du --files0-from=- -ck | awk '/total$/ {print $1}')

# Calculate the total required space
totalRequiredSpace=$((SPACE + torrentSize))
echo "Torrent Size: $torrentSize" >> $HOME/sizecheck.log
echo "Total Used: $SPACE/$reqSpace" >> $HOME/sizecheck.log
echo "Total Used if adding torrent: $totalRequiredSpace" >> $HOME/sizecheck.log

if [[ $totalRequiredSpace -ge $reqSpace ]]
then
  echo "not enough space" >> $HOME/sizecheck.log
  # echo "free $SPACE"
  exit 1
fi

echo "got space" >> $HOME/sizecheck.log
# echo "free $SPACE"
exit 0