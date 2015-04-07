#!/usr/bin/env bash

function deployer_ssher() {
	if [[ -z $username ]] || [[ -z $sshServer ]]; then
		error "You must configure the username and sshServer variables in the $deployerFile file"
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

function deployer_ssh_setup() {
	attempt 'setup ssh config on remote server'
	perform 'check if .ssh directory exists'
	if [[ ! -d ~/.ssh ]]; then
		echo -n 'Not found, creating'
		sudo mkdir ~/.ssh
		if [[ $? != 0 ]]; then
			error 'Unable to create directory, check permissions and try again.'
			return 1
		fi
    else
        performed
	fi

    perform 'check for ssh key'
	if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
		echo -n 'Not found creating key pair'
		ssh-keygen -t rsa
    else
        performed
	fi
	key=$(cat ~/.ssh/id_rsa.pub)
	perform 'check for key in remote auth keys file'
	keyresult=$(deployer_ssher 'cat ~/.ssh/authorized_keys' | grep "$key")
	filteredKeyResult="${keyresult//[[:space:]]/}"
	if [[ ! -z $filteredKeyResult ]]; then
		performed 'Key already exists on remote server!'
		return 0
    else
        warning 'Not found, adding key'
	fi
	deployer_run_command 'set key in remote ssh server' "touch ~/.ssh/authorized_keys && echo $key >> ~/.ssh/authorized_keys" 'Unable to reach server!'
}
