#!/bin/sh

# $2: full path to archive

ARCHIVE_PATH=$2
INTERNAL_JOB_ID=$3
ARCHIVE_FILENAME=$(basename $ARCHIVE_PATH)
ARCHIVE_DIRNAME=$(dirname $ARCHIVE_PATH)
USERNAME="cisnode"
# FIXME: use already set master hostname/IP
MASTER_NODE="ensipc469"

cd $ARCHIVE_DIRNAME

# Extract job files
tar -xf job.tar.gz

docker volume create --driver local \
  --opt type=none \
  --opt device=$ARCHIVE_DIRNAME \
  --opt o=bind \
  "volume_$INTERNAL_JOB_ID"

docker run -t -d \
  --cpus=1
  --memory=1G
  --storage-opt=5G
  --name $INTERNAL_JOB_ID \
  --mount source="volume_$INTERNAL_JOB_ID",target=/app \
  ubuntu

docker exec -ti $INTERNAL_JOB_ID sh -c "cd app && sh command.txt 1>stdout 2>stderr"

docker stop $INTERNAL_JOB_ID
docker rm $INTERNAL_JOB_ID

# Send back output and volume_dir files to master
tar -cvz result.tar.gz *

RESULTS_DIR_PATH="/home/$USERNAME/results/$INTERNAL_JOB_ID"

ssh $USERNAME@$MASTER_NODE -f "mkdir -p $RESULTS_DIR_PATH"
rsync -avz "result.tar.gz" $USERNAME@$MASTER_NODE:$RESULTS_DIR_PATH/result.tar.gz
