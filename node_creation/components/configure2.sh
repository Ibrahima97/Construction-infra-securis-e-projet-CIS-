MASTER_IP=$1
SEND_REGISTRATION="echo $MY_IP >> local_nodes"
cd /home/$USERNAME/
echo -e "\n\n\nPulling docker ubuntu image\n\n\n"
if ! docker pull ubuntu:latest; then
	echo -e "Warn: Failed to pull ubuntu image, you need to do it manually" >&2;
fi

if [ $# -eq 0 ]; then
	MASTER_IP=$(cat $MASTER_IP_FILE)
fi

#setting up local ssh configuration
echo -e "Host master\n\
    Hostname $MASTER_IP\n\
    StrictHostKeyChecking no" > .ssh/config

echo -e "\n\nActivating node on master"

#registering node
if ssh $MASTER_IP "$SEND_REGISTRATION"; then 
	echo "Done!"
else
	echo "ERROR: Master not found at" $MASTER_IP "(need to reconfigure?)"  >&2
fi
