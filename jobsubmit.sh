#!/bin/bash

#
# Triggered by incron upon receiving a tar.gz job request by a user
#

# Expected argument:
# - $1: Path to tar.gz archive
# - $2: username
if [ $# -ne 2 ]; then
    echo $#
    echo "Usage: $0 <archive> <username>"
    exit 1
fi

# Add the id
ID=$2
gunzip $1
tar -r -f $1 $ID
gzip $1


bash /home/$2/archive_sanity_checks.sh $1 job
if [ $? -ne 0 ]; then
  echo 'Sanity checks failed'
  exit 1
fi


INTERNAL_JOB_ID="$(( ( RANDOM % 10000000000 )  + 1 ))"
JOB_DIR="/home/$2/jobs/$INTERNAL_JOB_ID"
RESULT_DIR="/home/$2/results/$INTERNAL_JOB_ID"
MASTER_USERNAME="cisnode"
LOGS_DIR="/home/$2/LOGS/"

ARG_FILE_PATH="$1"
ARG_FILE_BASENAME=$(basename $ARG_FILE_PATH)

mkdir -p $LOGS_DIR
mkdir -p $RESULT_DIR

# Set a unique internal job ID
while [ -d $JOB_DIR ]; do
  INTERNAL_JOB_ID="$(( ( RANDOM % 10000000000 )  + 1 ))"
  JOB_DIR="/home/$2/jobs/$INTERNAL_JOB_ID"
done

LOGS_FILE="$LOGS_DIR/$INTERNAL_JOB_ID"

mkdir -p $JOB_DIR
tar -xvf $ARG_FILE_PATH -C $JOB_DIR
echo "Job $INTERNAL_JOB_ID triggered by $2" >$LOGS_FILE


# Sign the archive
TMP_DIR=$(mktemp -d -t SIG_CHECK-$(date +%Y-%m-%d-%H-%M-%S)-XXXXXXXXXXXXXXXXXXXXXXXX)
sha256sum $1 | cut -d ' ' -f 1 >$TMP_DIR/hash
openssl rsautl -in $TMP_DIR/hash -inkey ~/.ssh/id_rsa -sign -out signature.txt

# Put the signature in a tar, with the tar.gz
tar -czvf $JOB_DIR/$INTERNAL_JOB_ID.tar.gz $1 signature.txt


# Elit un node pour le faire tourner en "local" ou à distance
# Random pour l'instant, ~20% des cas sur autres nodes
if (($RANDOM%10 <= 7)); then
    # Fait tourner en local
    NB_LOCAL_NODES="$(wc -l < local_nodes)"
    LOCAL_NODE_NUMBER="$(( ( RANDOM % NB_LOCAL_NODES )  + 1 ))"
    ELECTED_NODE="$(head -n $LOCAL_NODE_NUMBER local_nodes | tail -1)"
else
    # Fait tourner sur un autre master
    NB_MASTER_NODES="$(wc -l < master_nodes)"
    MASTER_NODE_NUMBER="$(( ( RANDOM % NB_MASTER_NODES )  + 1 ))"
    ELECTED_NODE="$(head -n $MASTER_NODE_NUMBER master_nodes | tail -1)"
fi


echo "Execution on $ELECTED_NODE" >>$LOGS_FILE

#
# SLAVE
#

WORKER_JOB_ROOT_PATH="/home/$MASTER_USERNAME/jobs/$INTERNAL_JOB_ID"

# Create directory
ssh $MASTER_USERNAME@$ELECTED_NODE -f "mkdir -p $WORKER_JOB_ROOT_PATH"

# Copy to distant server
rsync -avz "$JOB_DIR/$INTERNAL_JOB_ID.tar.gz" $MASTER_USERNAME@$ELECTED_NODE:$WORKER_JOB_ROOT_PATH/$INTERNAL_JOB_ID.tar.gz
ssh $MASTER_USERNAME@$ELECTED_NODE -f "bash -x ./launch_docker_job.sh $WORKER_JOB_ROOT_PATH/$INTERNAL_JOB_ID.tar.gz $INTERNAL_JOB_ID"
