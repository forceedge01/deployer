#!/usr/bin/env bash

function deployer_init() {
	perform 'Create $deployerFile file for current project'
	if [[ -f ./$deployerFile ]]; then
		warning "$deployerFile already exists, run 'deployer config:edit' to edit this file'"
	else
		cp "$DEPLOYER_LOCATION/template/main.sh.dist" ./$deployerFile
		performed
	fi

	perform 'Initialize git repo (safe)'
	git init &>/dev/null
	performed
	perform "Set push configuration to 'current'"
	git config --global push.default current
	performed
	perform "Set pull configuration to 'current'"
	git config --global pull.default current
	performed
	info "Please configure the $deployerFile file in order to use deployer"
}

function deployer_use() {
	if [[ $localProjectLocation == $(pwd) ]]; then
		warning 'Project already selected'
		return
	fi
	
	attempt "set current directory as project dir"

	perform "locate '$deployerFile' file"
	if [[ ! -f ./$deployerFile ]]; then
		error "Unable to locate '$deployerFile' file in current directory, run 'deployer init' to create one."
		return 1
	fi
	performed
	perform "check if $projectFile file exists for deployer"
	if [[ -f $DEPLOYER_LOCATION/../config/$projectFile ]]; then
		performed
	else
		performed 'not found, creating...'
		perform "create $projectFile for deployer"
		sudo touch $DEPLOYER_LOCATION/../config/$projectFile
		if [[ $? == 0 ]]; then
			performed
		else
			error "unable to create $projectFile file, please resort to manual creation of file"
			return
		fi
	fi

	perform 'Make sure the logs folder/file exists'
	if [[ ! -f $projectsLog ]]; then
		mkdir $DEPLOYER_LOCATION/../logs
		touch $projectsLog
	fi
	performed

	perform 'set current project dir as deployer current project'
	currentDir=$(pwd)
	echo "#!/usr/bin/env bash
readonly localProjectLocation='$currentDir'" > "$DEPLOYER_LOCATION/../config/$projectFile"
	performed

	perform 'store current project dir in projects.log file'
	isInFile=$(cat $projectsLog | grep $currentDir)
	if [[ -z $isInFile ]]; then
		name=$(deployer_FolderNameFromPath $currentDir)
		echo "[$name] - $currentDir" >> $projectsLog
		performed
	else
		performed 'Already exists'
	fi
}