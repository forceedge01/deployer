#!/usr/bin/env bash

function Deployer_project_init() {
	attempt 'create a new project'

	# go to the home directory to make the dir, if path is not absoute, create it 
	# in the home dir
	cd

	if [[ -z "$1" ]]; then
		error 'Unable to initiate new project, need to specify path'
		return
	fi

	if [[ -d "$1" ]]; then
		error 'Unable to instantiate new project, path already exists'
		return
	fi

	if [[ ! -z "$2" ]]; then
		perform 'Clone repo'
		git clone "$2" "$1"
		performed
		
		cd "$1"
		
		perform 'Make sure master branch is checked out'
		git checkout master
		performed
	else
		perform 'Create project folder'
		mkdir -p "$1"
		performed

		cd "$1"
	fi

	deployer_init
	deployer_use

	info 'New project created: '$(pwd)
}

function deployer_select_project() {
	warning 'Select a project'
	deployer_project_location
	echo
	cat -n $projectsLog
	readUser 'Enter project number: '

	project=$(awk "NR==$input" $projectsLog)

	if [[ -z $project ]]; then
		error "Could not find project number $input"

		return
	fi
	
	project=$(echo $project | awk -F'] - ' '{print $2}')

	if [[ ! -d $project ]]; then
		error 'Project not found!'
		# perform 'Remove entry from projects file'
		# sed -i'.bk' -e "$input"d "$projectsLog"
		# performed

		return
	fi

	cd "$project"
	deployer_use
	info "Project set to: $project"
}

function Deployer_project_update() {
	cd $localProjectLocation
	branch=$(getCurrentBranchName)
	attempt "update current branch: $branch"

	if [[ $branch == 'master' ]]; then
		perform 'Update master branch'
		git pull
	else
		perform 'checkout and update master branch'
		git checkout master
		git pull

		if [[ $? != 0 ]]; then
			error 'Unable to update...'

			return
		fi
		performed

		perform "checkout $branch and merge master"
		git checkout $branch
		git merge master
	fi

	performed
}

function Deployer_project_save() {
	cd $localProjectLocation
	attempt 'save project'
	branch=$(getCurrentBranchName)

	if [[ $allowSaveToMaster == false && $branch == 'master' ]]; then
		error 'allowSaveToMaster is set to false, cannot save to master branch. Please create another branch and save again'

		return
	fi
	
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
	output=$(git push origin $branch)
	if [[ $(echo $?) != 0 ]]; then
		error 'Unable to push, aborting...'
		return
	fi
	performed

	if [[ -z $sshServer ]]; then
		warning 'sshServer not set, will not deploy'
		return
	fi

	currentBranch=$(git rev-parse --abbrev-ref HEAD)
	deployer_deploy $currentBranch
}

function Deployer_project_diff() {
	warning "showing diff on project"
	cd $localProjectLocation
	git diff $1
}

function Deployer_project_checkout() {
	cd $localProjectLocation

	if [[ -z $1 ]]; then
		warning 'Showing branches'
		git branch -a
		return
	fi
	
	warning "Checking out $1"
	if [[ $(git branch --list $1) == '' ]]; then
		info 'New branch checkout'
		git checkout master
		if [[ $? != 0 ]]; then
			error 'Unable to checkout, an error should be visible above'
			return
		fi
		git checkout -b $1
	else 
		info 'Existing branch checkout'
		git checkout $1
	fi
}

function Deployer_project_status() {
	warning "Show status of project"
	cd $localProjectLocation
	git status -sb
}

function Deployer_project_merge() {
	warning "Merging branch $1"

	if [[ $(git branch --list $1) == '' ]]; then
		error 'Branch not found'
		return
	fi

	git merge $1
}

function deployer_local_edit_project() {
	if [[ -z "$editor" ]]; then
		warning 'Editor not configured, using vim'
		editor='vim'
	fi

	$editor $localProjectLocation
}

function Deployer_local_run() {
	if [[ ! -d $localProjectLocation ]]; then
		return
	fi

	if [[ -z "$1" ]]; then
		# load libs
		if [[ -z $localProjectLocation ]]; then
			warning "Project Location >>> Please set project location to use deployer"
			return
		fi

		echo $(deployer_project_location)
		Deployer_project_status

		return 
	fi

	warning 'Running command on local project'
	cd $localProjectLocation
	$1
}

function deployer_project_location() {
	folder=$(deployer_FolderNameFromPath $localProjectLocation)
	gray "Project [$folder] >>> $localProjectLocation"
	echo
}

function deployer_open_web() {
	if [[ ! -z "$webURL" ]]; then 
		open $webURL
	else 
		error "Value for 'webURL' not specified in config" 
	fi
}

function Deployer_project_test() {
	warning 'Run test command'

	if [[ -z $testStart ]]; then
		error 'No command to run'
	else
		cd $localProjectLocation
		deployer_run_semicolon_delimited_commands "$testStart" true
	fi
}

function deployer_dev() {
	if [[ -z $devStart ]]; then
		warning 'Nothing todo...'
		return
	fi
	
	cd $localProjectLocation
	deployer_run_semicolon_delimited_commands "$devStart" false
}