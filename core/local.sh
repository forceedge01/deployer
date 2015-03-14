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

function Deployer_version() {
	cd $DEPLOYER_LOCATION && git status | head -n 1
	blue 'Deployer installation folder: '
	echo -n $DEPLOYER_LOCATION
}

function Deployer_config_edit {
	attempt 'edit project config file'
	$editor $localProjectLocation/deployer.config
}

function Deployer_update() {
	warning 'Updating deployer'
	cd $DEPLOYER_LOCATION && git pull origin && git pull origin --tags;
}

function Deployer_local_run() {
	if [[ -z "$1" ]]; then
		return 
	fi
	warning 'Running command on local project'
	cd $localProjectLocation; $1;
}