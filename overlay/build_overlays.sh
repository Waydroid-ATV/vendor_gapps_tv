#!/bin/bash

set -e

GARCH=$1
GOUT=$2

SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR"

OVERLAYS=$(for dir in $(ls -d */); do echo ${dir%%/}; done)

croot 2>/dev/null || cd ../../../

source build/envsetup.sh
breakfast gapps_$GARCH
m installclean
mkdir -p $OUT   # $OUT may not exist yet, but we need to start creating the log file now
m $OVERLAYS | tee $OUT/.log

RELOUT=$(echo $OUT | sed "s#^${ANDROID_BUILD_TOP}/##")
LOC="$(cat $OUT/.log | sed -r -e 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' -e 's/^\[ {0,2}[0-9]{1,3}% [0-9]{1,6}\/[0-9]{1,6}\] +//' \
            | grep '^Install: ' | grep "$RELOUT" | cut -d ':' -f 2)"
FILES=$(echo $LOC | tr " " "\n" | sed "s#.*${RELOUT}##" | sort | uniq)

for TARGET in $FILES; do
    mkdir -p $(dirname $GOUT/$TARGET) && cp $OUT/$TARGET $GOUT/$TARGET
done
