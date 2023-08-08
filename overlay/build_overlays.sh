#!/bin/bash

set -e

GARCH=$1
GOUT=$2

SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR"

OVERLAYS=$(for dir in $(ls -d */); do echo ${dir%%/}; done)

croot 2>/dev/null || cd ../../../

source build/envsetup.sh
breakfast gapps_tv_$GARCH
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

# Generate temporary signing keys
PRIVATE_KEY=$(mktemp)
PRIVATE_KEY_PK8=$(mktemp)
PUBLIC_KEY_PEM=$(mktemp)

openssl genrsa -f4 2048 > $PRIVATE_KEY
openssl pkcs8 -in $PRIVATE_KEY -topk8 -outform DER -out $PRIVATE_KEY_PK8 -nocrypt
openssl req -new -x509 -sha256 -key $PRIVATE_KEY -out $PUBLIC_KEY_PEM -days 10000 -subj '/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'

# Resign all overlay apks
for TARGET in $FILES; do
    java -Xmx2048m -jar $TOP/build/sign/signapk.jar $PUBLIC_KEY_PEM $PRIVATE_KEY_PK8 $GOUT/$TARGET $GOUT/${TARGET}.signed
    mv $GOUT/$TARGET.signed $GOUT/$TARGET
done

# RIP
rm $PRIVATE_KEY $PRIVATE_KEY_PK8 $PUBLIC_KEY_PEM
