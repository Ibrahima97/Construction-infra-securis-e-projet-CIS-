#init
CISNODEFILE=$1
echo -e "\n\n\nThis machine's IPv4 is" $MY_IP "\n\n\n"
echo -e "Installing required packages\n\n"
apt update;
apt install --assume-yes apt-transport-https ca-certificates curl gnupg2 software-properties-common;
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -;
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable";
apt update;
apt install --assume-yes $PKG_LIST;


echo -e "\n\n\nAdd $USERNAME to group docker\n\n\n"
#should be always but I don't know how to use export
PATH=/usr/sbin:$PATH
adduser $USERNAME docker
echo -e "\n\n\nSet SSH private key\n\n\n"
mkdir $SSH_DIR
chown $USERNAME $SSH_DIR
cp $D/$PVT_KEYFILE $SSH_DIR/id_rsa
chmod 400 $SSH_DIR/id_rsa
chown $USERNAME $SSH_DIR/id_rsa
#Copying JOB_LAUNCHER file
if ! cp $D/$JOB_LAUNCHER /home/$USERNAME/; then
	echo "Warning: Jobs Launcher script not found" 1>&2
else 
	chmod 500 /home/$USERNAME/$JOB_LAUNCHER
	chown $USERNAME /home/$USERNAME/$JOB_LAUNCHER
fi

#Probing
echo -n -e "\nPlease enter master's IP:";
read MASTER_IP
n_try=1;
max_tries=5
while ! ssh -o ConnectTimeout=2 -o ConnectionAttempts=1 -o StrictHostKeyChecking=no -i $SSH_DIR/id_rsa $USERNAME@$MASTER_IP "true"  && [ $n_try -le $max_tries ]	; do
	echo "Probing server failed (wrong ip $MASTER_IP?) try n:$n_try" 1>&2
	let n_try=n_try+1
	echo -n -e "\nPlease enter a new master's IP/hostname:";
	read MASTER_IP
done
if [ $n_try -gt $max_tries ]; then
	echo "cannot connect to the master" 1>&2
	exit -1
fi
n_try=""

echo $MASTER_IP > /home/$USERNAME/$MASTER_IP_FILE
chmod 644 /home/$USERNAME/$MASTER_IP_FILE

#Configuring SSH Daemon
cat $D/cisnodekey.pub >> /home/$USERNAME/.ssh/authorized_keys
chown $USERNAME /home/$USERNAME/.ssh/authorized_keys
echo -e Match Address $MASTER_IP "\n\tPubkeyAuthentication yes" >> $D/sshd_config
cp $D/sshd_config /etc/ssh/sshd_config
service ssh start

# ENTER user cisnode
echo -e "\n\n\nRunning $USERNAME configuration script\n\n\n"
sudo -u $USERNAME /home/$USERNAME/$CISNODEFILE $MASTER_IP

