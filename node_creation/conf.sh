#!/bin/bash
DNAME="components"
BASE="$( cd "$(dirname "$0")" ; pwd -P )"
D=$BASE"/"$DNAME

if [ ! $BASE = "/root" ]; then
	echo "Going to /root..."
	cp -r $D $0 /root/;
	chmod +x /root/conf.sh /root/components/get_ip.sh
	cd
	./conf.sh
	exit 0
fi

service ssh stop
echo -e "BEGIN\n\n\n"

FILES="$D/Variables "
FILESROOT=$FILES"$D/configure1.sh "
FILESCISNODE=$FILES"$D/configure2.sh "
BBASH="#\x21/bin/bash\n"
CISNODEFILE="configure_cisnode.sh"
ROOTFILE="configure_root.sh"
#username must be changed also in components/Variables
USERNAME="cisnode"

echo -e "\n\n\nCreating secondary scripts\n\n\n"
echo -e $BBASH > $ROOTFILE
MY_IP=$($D/get_ip.sh)
if [ $MY_IP == "" ]; then
	echo -e "\nFailed to get ethernet IP address (uplink?)"  1>&2
	exit -1
fi
cp $ROOTFILE $CISNODEFILE
cat $FILESROOT >> $ROOTFILE
cat $FILESCISNODE >> $CISNODEFILE


mkdir /home/$USERNAME/$DNAME
cp $D/get_ip.sh /home/$USERNAME/$DNAME/get_ip.sh
chown -R $USERNAME /home/$USERNAME/$DNAME
chmod +rx /home/$USERNAME/$DNAME/get_ip.sh
chmod +x $ROOTFILE
mv $CISNODEFILE /home/$USERNAME/$CISNODEFILE
chmod +x /home/$USERNAME/$CISNODEFILE
chown $USERNAME /home/$USERNAME/$CISNODEFILE
echo -e "\n\n\nRunning root configuration script\n\n\n"
./$ROOTFILE $CISNODEFILE


if [ $PWD = "/root" ]; then
	rm -r components conf.sh $ROOTFILE
fi
