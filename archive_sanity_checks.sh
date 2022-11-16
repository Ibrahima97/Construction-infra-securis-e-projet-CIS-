#!/bin/bash

if (( $# < 2 )); then
    echo "Usage: $1 <filename> <job/result>"
    exit 1
fi

ARCHIVE_PATH=$1
ARCHIVE_TYPE=$2
ARCHIVE_FILE=$(basename $ARCHIVE_PATH)
PUB_KEY_PATH="/home/$USER/DER"

# Creating the DER file for signature verification if it does not exist
if [ ! -e $PUB_KEY_PATH ]; then
    openssl rsa -in ~/.ssh/id_rsa -out $PUB_KEY_PATH -outform DER -pubout
fi

REQUIRED_FILES=()
if [ $(echo $ARCHIVE_TYPE | grep -i 'job') ]; then
    REQUIRED_FILES=('cmd.txt' 'job_files/')
elif [ $(echo $ARCHIVE_TYPE | grep -i 'result') ]; then
    REQUIRED_FILES=('stdout' 'stderr' 'id.txt' 'job_files/')
else
    echo "Wrong argument, should be job or result instead of $ARCHIVE_TYPE"
fi

if [ -e $ARCHIVE_PATH ]; then
    # Check file type
    if [ $(file $ARCHIVE_PATH | grep -c 'gzip compressed data') -ne 0 ]; then
        echo "FATAL: Invalid file type"
        exit 1
    fi
    echo "OK: file type consistent with specification"

    # Check hierarchy

    for _file in "${required_files[@]}"; do
        if [ $(tar -tf $ARCHIVE_PATH | grep -c $_file) -lt 1 ]; then
            echo "FATAL: $_file is missing in the hierarchy"
            exit 1
        fi
    done
    echo "OK: file hierarchy consistent with specification"

    if [ $(echo $ARCHIVE_TYPE | grep -i 'result') ]; then
        TMP_DIR=$(mktemp -d -t SIG_CHECK-$(date +%Y-%m-%d-%H-%M-%S)-XXXXXXXXXXXXXXXXXXXXXXXX)
        cp $ARCHIVE_PATH $TMP_DIR/$ARCHIVE_FILE
        cd $TMP_DIR
        mkdir -p $TMP_DIR/extracted
        tar -xf $TMP_DIR/$ARCHIVE_FILE -C $TMP_DIR/extracted
        sha256sum $TMP_DIR/extracted/job.tar.gz >computed_hash
        cat computed_hash >computed_hash
        openssl rsautl -verify -in $TMP_DIR/extracted/signature.txt -inkey $PUB_KEY_PATH -pubin -keyform DER -out expected_hash
        if [ $(grep -i expected_hash computed_hash) ]; then
            echo "Signature verification failed"
            exit 1
        else
            echo "OK: signature check"
        fi
    fi
else
    echo "$ARCHIVE_PATH does not exist"
    exit 1
fi

echo 'OK: sanity checks passed'
