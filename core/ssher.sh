#!/usr/bin/env bash

function deployer_ssher() {
	if [[ -z $username ]] || [[ -z $sshServer ]]; then
		error 'You must configure the username and sshServer variables in the deployer.config file'
		return
	fi

	if [[ ! -z $1 ]]; then
		if [[ $verbose == 1 ]]; then
			echo "Executing '$1' on '$sshServer'..."
		fi
		ssh -t $username@$sshServer "$1" 2> /dev/null
		
		return 0
	fi

	echo "Logging into '$sshServer'..."
	ssh $username@$sshServer
}

function deployer_ssher_toDir() {
	deployer_ssher "cd $remoteProjectLocation &> /dev/null; $1"
}