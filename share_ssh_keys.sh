#!/bin/bash
# share_ssh_keys.sh

# Test has keys shared with HOST
function _ssh_test {
    local HOST=$1
    ssh -q -o "BatchMode=yes" $HOST "echo 2>&1" && echo "OK" || echo "NOK"
}

# Share SSH public keys with HOST
function _ssh_share_keys {
    local HOST=$1
    local PUB_KEY=~/.ssh/id_rsa.pub
    local KEY_REPO=.ssh/authorized_keys

    if [ "OK" = $(_ssh_test $HOST) ]; then
        echo SSH keys are already shared.
        return
    fi

    if [ ! -f $PUB_KEY ]; then
        echo Generating keys
        ssh-keygen -b 2048 -t rsa
    fi 

    echo Sharing ssh keys with $HOST
    cat $PUB_KEY | ssh -oStrictHostKeyChecking=no -oCheckHostIP=no $HOST "
        if [ ! -d .ssh ]; then
            mkdir .ssh
        fi
        chmod 700 .ssh
        cat - >>$KEY_REPO
        chmod 600 $KEY_REPO"

    if [ "OK" = $(_ssh_test $HOST) ]; then
        echo SSH keys are shared succesfully.
    else
        echo ERROR: Sharing SSH keys failed.
    fi
}

###    ###   ######   ###  ###    ###
####  ####  ###  ###  ###  #####  ###
### ## ###  ########  ###  ###  #####
###    ###  ###  ###  ###  ###    ###

if [ ! "$#" = "1" ]; then

	echo "Share SSH keys with given server."
	echo "USAGE: share_ssh_keys.sh server_name"
	exit 1
fi

_ssh_share_keys "$1"

