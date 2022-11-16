#!/bin/sh

#
# script to create and configure the ssh server
#

LOG_FILE="configure_master.log"


CUR_USERNAME="anonymous_user"
echo "[$(date +'%Y-%m-%d %T')] Creating user $CUR_USERNAME" >> ${LOG_FILE}
sudo adduser $CUR_USERNAME --gecos "anonymous_user,RoomNumber,WorkPhone,HomePhone" --disabled-password
if [ $? -ne 0 ]; then
	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to create user $CUR_USERNAME , ABORTING..." >> ${LOG_FILE} 
	exit 1
fi
echo "$CUR_USERNAME:a" | sudo chpasswd
mkdir /home/$CUR_USERNAME/.ssh
if [ $? -ne 0 ]; then
	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to create /home/$CUR_USERNAME/.ssh/ , ABORTING..." >> ${LOG_FILE} 
	exit 1
fi
touch /home/$CUR_USERNAME/.ssh/authorized_keys
if [ $? -ne 0]; then
	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to create /home/$CUR_USERNAME/.ssh/authorized_keys , ABORTING..." >> ${LOG_FILE} 
	exit 1
fi
echo "[$(date +'%Y-%m-%d %T')] User $CUR_USERNAME successfully created" >> ${LOG_FILE}


CUR_USERNAME="known_node"
echo "[$(date +'%Y-%m-%d %T')] Creating user $CUR_USERNAME" >> ${LOG_FILE}
sudo adduser $CUR_USERNAME --gecos "known_node,RoomNumber,WorkPhone,HomePhone" --disabled-password
if [ $? -ne 0]; then
	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to create user $CUR_USERNAME , ABORTING..." >> ${LOG_FILE} 
	exit 1
fi
echo "$CUR_USERNAME:b" | sudo chpasswd
mkdir /home/$CUR_USERNAME/.ssh
if [ $? -ne 0]; then
	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to create /home/$CUR_USERNAME/.ssh/ , ABORTING..." >> ${LOG_FILE} 
	exit 1
fi
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC894jEHEvS6C0QypRrx/BMkD39WEhJfCheY6mkOY7YVzj9vAHgC+b5Pl+UA8QYc+0eP1XMCKipAvNHOdQFCm6oQ88Uws47uonARqdFHkoRehrTkik6y2JJ5VvGS98XwC7MFBnEV0Frt+RM9gzsBbAZe0gCFhbG6rUo24Fq6n2uoPUWoCCGwN7ZMPtFsftReuJUkdd1frm4mhcxpGzUr7kdfPMyAirvYYt90zUXKVQHYLB5usK1bZavNAbeVr9hoX4kBxXxWD6ToAmgGCTFtgIIJvOd9B5acrkwR/I/A5Q9Q95QF7Rz0M1bKl/8lgwasFmwOoJPrfmfuEF4aPtzrKsR" > /home/$CUR_USERNAME/.ssh/authorized_keys
touch /home/$CUR_USERNAME/local_nodes
if [ $? -ne 0 ]; then
	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to create /home/$CUR_USERNAME/local_nodes , ABORTING..." >> ${LOG_FILE} 
	exit 1
fi
echo "[$(date +'%Y-%m-%d %T')] User $CUR_USERNAME successfully created" >> ${LOG_FILE}


CUR_USERNAME="master_2"
echo "[$(date +'%Y-%m-%d %T')] Creating user $CUR_USERNAME" >> ${LOG_FILE}
sudo adduser $CUR_USERNAME --gecos "master_2,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "$CUR_USERNAME:c" | sudo chpasswd
mkdir /home/$CUR_USERNAME/.ssh
if [ $? -ne 0 ]; then
	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to create /home/$CUR_USERNAME/.ssh/ , ABORTING..." >> ${LOG_FILE} 
	exit 1
fi

echo '#!/bin/bash
if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
    if [[ "$SSH_ORIGINAL_COMMAND" =~ ^scp\  ]]; then
        echo "`/bin/date`: $SSH_ORIGINAL_COMMAND" >> $HOME/ssh-command-log
        exec $SSH_ORIGINAL_COMMAND
    else
        echo "`/bin/date`: DENIED $SSH_ORIGINAL_COMMAND" >> $HOME/ssh-command-log
    fi
fi' > /home/$CUR_USERNAME/.ssh/checkssh.sh

chmod 555 /home/$CUR_USERNAME/.ssh/checkssh.sh
if [ $? -ne 0 ]; then
	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to chmod on /home/$CUR_USERNAME/.ssh/checkssh.sh , ABORTING..." >> ${LOG_FILE} 
	exit 1
fi

echo "command=\"/home/$CUR_USERNAME/.ssh/checkssh.sh\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa key_$CUR_USERNAME" > /home/$CUR_USERNAME/.ssh/authorized_keys
echo "IP_$CUR_USERNAME" > /home/$CUR_USERNAME/master_node_IP
echo "[$(date +'%Y-%m-%d %T')] User $CUR_USERNAME successfully created" >> ${LOG_FILE}


CUR_USERNAME="master_3"
echo "[$(date +'%Y-%m-%d %T')] Creating user $CUR_USERNAME" >> ${LOG_FILE}
sudo adduser $CUR_USERNAME --gecos "master_3,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "$CUR_USERNAME:d" | sudo chpasswd
mkdir /home/$CUR_USERNAME/.ssh
if [ $? -ne 0 ]; then
	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to create /home/$CUR_USERNAME/.ssh/ , ABORTING..." >> ${LOG_FILE} 
	exit 1
fi

echo '#!/bin/bash
if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
    if [[ "$SSH_ORIGINAL_COMMAND" =~ ^scp\  ]]; then
        echo "`/bin/date`: $SSH_ORIGINAL_COMMAND" >> $HOME/ssh-command-log
        exec $SSH_ORIGINAL_COMMAND
    else
        echo "`/bin/date`: DENIED $SSH_ORIGINAL_COMMAND" >> $HOME/ssh-command-log
    fi
fi' > /home/$CUR_USERNAME/.ssh/checkssh.sh

chmod 555 /home/$CUR_USERNAME/.ssh/checkssh.sh
if [ $? -ne 0 ]; then
	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to chmod on /home/$CUR_USERNAME/.ssh/checkssh.sh , ABORTING..." >> ${LOG_FILE} 
	exit 1
fi

echo "command=\"/home/$CUR_USERNAME/.ssh/checkssh.sh\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa key_$CUR_USERNAME" > /home/$CUR_USERNAME/.ssh/authorized_keys
echo "IP_$CUR_USERNAME" > /home/$CUR_USERNAME/master_node_IP
echo "[$(date +'%Y-%m-%d %T')] User $CUR_USERNAME successfully created" >> ${LOG_FILE}


exit 0