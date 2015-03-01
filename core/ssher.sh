#!/usr/bin/env bash

source $DEPLOYER_LOCATION/../config/main.sh

function deployer_ssher() {
	if [[ ! -z $1 ]]; then
		echo "Executing '$1' on '$sshServer'..."
		ssh $username@$sshServer "$1"
		
		return 0
	fi

	echo "Logging into '$sshServer'..."
	ssh $username@$sshServer
}

function deployer_ssher_toDir() {
	deployer_ssher "cd $remoteProjectLocation; $1"
}