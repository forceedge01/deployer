#!/usr/bin/env bash

function deployer_ssher() {
	if [[ -z $username ]] || [[ -z $sshServer ]]; then
		error "You must configure the username and sshServer variables in the $deployerFile file"
		return
	fi

	if [[ ! -z "$@" ]]; then
		if [[ $verbose == 1 ]]; then
			echo "Executing '$@' on '$sshServer'..."
		fi
		ssh -t $username@$sshServer "$@" 2> /dev/null
		
		return 0
	fi

	echo "Logging into '$sshServer'..."
	ssh $username@$sshServer
}

function deployer_ssher_toDir() {
	execCommand="$@"
	if [[ -z "$execCommand" ]]; then
		execCommand='bash'
	fi

	execCommand="cd $remoteProjectLocation; $execCommand"

	attempt "Running command: '$execCommand'"
	deployer_ssher "$execCommand"
}

function Deployer_ssh_revoke() {
	attempt 'revoke access'

	if [[ ! -f "$sshKeyFile" ]]; then
		error 'sshKey file not found at: '$sshKeyFile', please set the sshKeyFile variable in deploy.conf to specify where it is'

		return
	fi

	key=$(cat $sshKeyFile)

	if [[ -z "$key" ]]; then
		error 'No key found at '$sshKeyFile ', if the is set in a different file, please set the sshKeyFile variable in your config file'

		return
	fi

	perform 'Remove ssh key from remote server'
	deployer_ssher "sed -i'.bk' '\|$key|d' \$HOME/.ssh/authorized_keys"
	performed	

	info 'SSH access revoked'
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

	deployer_ssher_toDir "touch ~/.ssh/authorized_keys && echo '$key' >> ~/.ssh/authorized_keys"
	performed 'Key added.'
}

function deployer_remote_keys() {
	attempt 'show ssh keys'
	deployer_ssher "cat ~/.ssh/authorized_keys"
}