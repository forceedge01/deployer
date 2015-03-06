#!/usr/bin/env bash

function deployer_init() {
	if [[ -f ./deployer.config ]]; then
		error "deployer.config already exists, run 'deployer config edit' to edit this file'"
	else
		perform 'Create deployer.config file for current project'
		cp "$DEPLOYER_LOCATION/template/main.sh.dist" ./deployer.config
		performed
		info 'Please configure the deployer.config file in order to use deployer'
	fi
}

function deployer_use() {
	attempt "set current directory as project dir"
	perform "locate 'deployer.config' file"
	if [[ ! -f ./deployer.config ]]; then
		error "Unable to locate 'deployer.config' file in current directory, run 'deployer init' to create one."
		return 1
	fi
	performed
	perform 'check if project.sh file exists for deployer'
	if [[ -f $DEPLOYER_LOCATION/../config/project.sh ]]; then
		performed
	else
		performed 'not found, creating...'
		perform 'create project.sh for deployer'
		sudo touch $DEPLOYER_LOCATION/../config/project.sh
		if [[ $? == 0 ]]; then
			performed
		else
			error 'unable to create project.sh file, please resort to manual creation of file'
			return
		fi
	fi
	perform 'set current project dir as deployer current project'
	currentDir=$(pwd)
	echo "#!/usr/bin/env bash
readonly localProjectLocation='$currentDir'" > "$DEPLOYER_LOCATION/../config/project.sh"
	performed
}

function deployer_local_update() {
	cd $localProjectLocation && git pull origin
}

function deployer_local_edit_project() {
	if [[ -z "$editor" ]]; then
		warning 'Editor not configured, using vim'
		editor='vim'
	fi

	$editor $localProjectLocation
}

function deployer_local_upload() {
	if [[ -z "$1" ]]; then
		error 'You must specify the file to upload'
		return
	fi
	attempt "upload file/folder to $sshServer"
	perform 'Check path provided'
	recurse=''
	if [[ -f "$1" ]]; then
		performed 'File'
	elif [[ -d "$1" ]]; then
		performed 'Folder'
		recurse='-r'
	else
		error 'The path specified is not a file or folder'
		return 234
	fi
	perform 'Make sure the uploads dir exists'
	deployer_ssher "mkdir -p $uploadsPath"
	performed
	perform 'SCP file/folder to server'
	scp $recurse "$1" "$username@$sshServer:$uploadsPath"
	performed
	perform 'Show uploads folder contents'
	deployer_ssher "ls -la $uploadsPath | sed 2,3d"
}