#!/bin/bash

# script new-user
# create a new user

LOG_FILE="user_creation.log"

echo "[$(date +'%Y-%m-%d %T')] Beginning of the creation of a new user" >> ${LOG_FILE}

# Check if the user has provided the good number of args
if (($# != 0)); then
	echo "Error: Too many arguments, usage: $0"
	echo "[$(date +'%Y-%m-%d %T')] ERROR: User has provided too much args, ABORTING..." >> ${LOG_FILE}
	exit 1
fi

# Ask for the public key of user
echo "Entrez ici votre clé publique : "
echo "[$(date +'%Y-%m-%d %T')] Reading the public key of the new user" >> ${LOG_FILE}
read PUBLIC_KEY
echo "[$(date +'%Y-%m-%d %T')] Key red: $PUBLIC_KEY" >> ${LOG_FILE}

# Check key security with its size
echo "[$(date +'%Y-%m-%d %T')] Checking the length of the key" >> ${LOG_FILE}
CLEANED_PUBLIC_KEY=$(echo "$PUBLIC_KEY"| cut -d'=' -f 1)
STRLEN=${#CLEANED_PUBLIC_KEY}
if (($STRLEN < 256)); then
	echo "Error: Key is too short. For security reasons, generate a new one and run this script again..."
	echo "[$(date +'%Y-%m-%d %T')] ERROR: User has provided a key too small, ABORTING..." >> ${LOG_FILE}
	exit 1
fi


# Take a unique ID
# USERID exists to enter in the loop
echo "[$(date +'%Y-%m-%d %T')] Generating a unique USERID" >> ${LOG_FILE}
USERID="root"	
while (id -u $USERID &>/dev/null)
do
	USERNO=$RANDOM
	USERID="user${USERNO}"
done

echo CLEANED_PUBLIC_KEY > newusers/
# # Create the user and its home
# echo "[$(date +'%Y-%m-%d %T')] User $USERID requested" >> ${LOG_FILE}
# sudo su -c "useradd $USERID --home /home/$USERID/ --create-home --shell /bin/bash"
# #if [ $? ]; then
# #	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to create $USERID , ABORTING..." >> ${LOG_FILE} 
# #	exit 1
# #fi
# echo "[$(date +'%Y-%m-%d %T')] User $USERID created with its home /home/$USERID/" >> ${LOG_FILE} 
# 
# # Create .ssh/ in user home
# sudo su -c "mkdir /home/$USERID/.ssh/"
# #if [ $? ]; then
# #	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to create .ssh/ for $USERID ,ABORTING..." >> ${LOG_FILE} 
# #	exit 1
# #fi
# echo "[$(date +'%Y-%m-%d %T')] /home/$USERID/.ssh/ folder generated for $USERID" >> ${LOG_FILE}
# 
# # Create the authorized_keys file 
# sudo su -c "echo \"$PUBLIC_KEY\" >> /home/$USERID/.ssh/authorized_keys"
# #if [ $? ]; then
# #	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to create authorized_keys for $USERID ,ABORTING..." >> ${LOG_FILE} 
# #	exit 1
# #fi
# echo "[$(date +'%Y-%m-%d %T')] Added $USERID public key to /home/$USERID/.ssh/authorized_keys" >> ${LOG_FILE}
# 
# # Change the owner of .ssh/ and authorized_keys 
# sudo su -c "chown -R $USERID /home/$USERID/.ssh/"
# #if [ $? ]; then
# #	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to change owner recursively of /home/$USERID/.ssh/ to $USERID ,ABORTING..." >> ${LOG_FILE}
# #	exit 1
# #fi
# echo "[$(date +'%Y-%m-%d %T')] Set the owner of .ssh folder and authorized_keys file to $USERID" >> ${LOG_FILE}
# 
# # Change the rights of .ssh/
# sudo su -c "chmod 700 /home/$USERID/.ssh"
# #if [ $? ]; then
# #	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to change rights of /home/$USERID/.ssh/, ABORTING..." >> ${LOG_FILE} 
# #	exit 1
# #fi
# 
# # Change the rights of authorized_keys
# sudo su -c "chmod 600 /home/$USERID/.ssh/authorized_keys"
# #if [ $? ]; then
# #	echo "[$(date +'%Y-%m-%d %T')] ERROR: Failed to change rights of /home/$USERID/.ssh/authorized_keys, ABORTING..." >> ${LOG_FILE}
# #	exit 1
# #fi
# echo "[$(date +'%Y-%m-%d %T')] Setting appropriate rights on .ssh and authorized_keys" >> ${LOG_FILE}
# 
# # Tell the user it's done
# echo ""
# echo "-----------------------------------------------------------"
# echo "Création de compte réussie !"
# echo "Vous êtes l'utilisateur $USERID"
# echo "Notez-le bien, vous en aurez besoin pour vous connecter"
# echo "-----------------------------------------------------------"
# exit 0
