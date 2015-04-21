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
	info "Please configure the $deployerFile file in order to use deployer"
}

function deployer_use() {
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
	perform 'set current project dir as deployer current project'
	currentDir=$(pwd)
	echo "#!/usr/bin/env bash
readonly localProjectLocation='$currentDir'" > "$DEPLOYER_LOCATION/../config/$projectFile"
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
	$editor $localProjectLocation/$deployerFile
}

function Deployer_update() {
	warning 'Updating deployer'
	cd $DEPLOYER_LOCATION && git pull origin && git pull origin --tags
}

function Deployer_local_run() {
	if [[ -z "$1" ]]; then
		return 
	fi
	warning 'Running command on local project'
	cd $localProjectLocation
	$1
}

function deployer_dev() {
	if [[ -z $devStart ]]; then
		warning 'Nothing todo...'
	fi
	
	perform 
	performed "$devStart"
	cd $localProjectLocation
	$devStart
}

function Deployer_project_save() {
	cd $localProjectLocation
	attempt 'save project'
	changes=$(git status -s)
	if [[ -z $changes ]]; then
		warning 'No changes detected'
		unpushed=$(git log --branches --not --remotes --simplify-by-decoration --decorate --oneline --abbrev-commit)
		result=$?
		if [[ ! -z $unpushed ]]; then
			info 'Unpushed Commit(s)'
			git log --branches --not --remotes --simplify-by-decoration --decorate --oneline --abbrev-commit
			printForRead 'You have unpushed commits, would you like to push them? [Y/N]: '
			if [[ $(userChoice) == 'Y' ]]; then
				echo
				perform 'Push local changes'
				git push
				result=$?
			fi
			echo
		fi
		if [[ $result != 0 ]]; then
			error 'There was an error, please review and re-run this command'
			return
		fi

		printForRead 'deploy current branch? [Y/N]: '
		if [[ $(userChoice) != 'Y' ]]; then
			return
		fi
		echo
		currentBranch=$(git rev-parse --abbrev-ref HEAD)
		deployer_deploy $currentBranch

		return
	fi
    perform 'Add all files for commit'
	git add --all
	performed
	perform 'Show branch/files'
	git status -sb
	readUser 'Please enter commit message: '
    git commit -m "$input"
	perform 'Push changes'
	branch=$(getCurrentBranchName)
	output=$(git push origin $branch)
	if [[ $(echo $?) != 0 ]]; then
		error 'Unable to push, aborting...'
		return
	fi
	performed
	currentBranch=$(git rev-parse --abbrev-ref HEAD)
	deployer_deploy $currentBranch
}

Deployer_project_diff() {
	warning "showing diff on project"
	cd $localProjectLocation
	git diff $1
}

Deployer_project_status() {
	warning "Show status of project"
	cd $localProjectLocation
	git status
}

function Deployer_repo_url() {
	substring=$(echo $repo | grep http)
	if [[ -z $substring ]]; then # is a ssh url e.g git@bitbucket.org:wqureshi/driving-theory-test-project.git
		# explode on @, then on : and trim .git
		IFS='@' read -ra ADDR <<< "$repo"
		IFS=':' read -ra ADDR <<< "${ADDR[1]}"
		url="https://${ADDR[0]}/${ADDR[1]}"
	else # is a http url e.g https://wqureshi@bitbucket.org/wqureshi/driving-theory-test-project.git
		# remote everything before @ sign and trim .git
		IFS='@' read -ra ADDR <<< "$repo"
		url='https://'${ADDR[1]}
	fi
	
	echo "$url"
}