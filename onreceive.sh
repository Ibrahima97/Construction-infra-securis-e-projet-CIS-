#!/bin/bash

#
# Triggered by incron upon receiving a tar.gz job request by a master
#

# Expected argument:
# - $1: Path to tar.gz archive
if [ $# -ne 1 ]; then
  echo $#
  echo "Usage: $0 <archive>"
  exit 1
fi

bash /home/$USER/archive_sanity_checks.sh $1 job
if [ $? -ne 0 ]; then
  echo 'Sanity checks failed'
  exit 1
fi

INTERNAL_JOB_ID="$(( ( RANDOM % 10000000000 )  + 1 ))"
JOB_DIR="/home/$USER/jobs/$INTERNAL_JOB_ID"
RESULT_DIR="/home/$USER/results/$INTERNAL_JOB_ID"
MASTER_USERNAME="cisnode"
LOGS_DIR="/home/$USER/LOGS/"

ARG_FILE_PATH="$1"
ARG_FILE_BASENAME=$(basename $ARG_FILE_PATH)

mkdir -p $LOGS_DIR
mkdir -p $RESULT_DIR

# Set a unique internal job ID
while [ -d $JOB_DIR ]; do
  INTERNAL_JOB_ID="$(( ( RANDOM % 10000000000 )  + 1 ))"
  JOB_DIR="/home/$USER/jobs/$INTERNAL_JOB_ID"
done

LOGS_FILE="$LOGS_DIR/$INTERNAL_JOB_ID"

mkdir -p $JOB_DIR
tar -xvf $ARG_FILE_PATH -C $JOB_DIR
echo "Job $INTERNAL_JOB_ID triggered by $USER" >$LOGS_FILE


# Fait tourner en local
NB_LOCAL_NODES="$(wc -l < local_nodes)"
LOCAL_NODE_NUMBER="$(( ( RANDOM % NB_LOCAL_NODES )  + 1 ))"
ELECTED_NODE="$(head -n $LOCAL_NODE_NUMBER local_nodes | tail -1)"


echo "Execution on $ELECTED_NODE" >>$LOGS_FILE

#
# SLAVE
#

WORKER_JOB_ROOT_PATH="/home/$MASTER_USERNAME/jobs/$INTERNAL_JOB_ID"

# Create directory
ssh $MASTER_USERNAME@$ELECTED_NODE -f "mkdir -p $WORKER_JOB_ROOT_PATH"

# Copy to distant server
rsync -avz "$JOB_DIR/job.tar.gz" $MASTER_USERNAME@$ELECTED_NODE:$WORKER_JOB_ROOT_PATH/job.tar.gz
ssh $MASTER_USERNAME@$ELECTED_NODE -f "bash -x ./launch_docker_job.sh $WORKER_JOB_ROOT_PATH/job.tar.gz $INTERNAL_JOB_ID"
