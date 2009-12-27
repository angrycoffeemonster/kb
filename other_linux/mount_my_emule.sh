#/bin/sh
REMOTE_USERNAME="venator"
REMOTE_HOST="venator.ath.cx"
REMOTE_PATH="/home/venator/"

LOCAL_MOUNTPOINT="/home/venator/mountpoint"

#=============================================

MOUNT_GREP=`mount|grep $LOCAL_MOUNTPOINT`

if [ "$MOUNT_GREP" = "" ]; then
	sshfs $REMOTE_USERNAME@$REMOTE_HOST:$REMOTE_PATH $LOCAL_MOUNTPOINT
fi

nautilus "$LOCAL_MOUNTPOINT/aMule/Incoming"
