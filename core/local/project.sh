#!/usr/bin/env bash

function Deployer_project_init() {
	attempt 'create a new project'

	# if path is not absoute, create it 
	# in the current directory as that is what is expected
	cd $(pwd)

	if [[ -z "$1" ]]; then
		error 'Unable to initiate new project, need to specify path'
		return
	fi

	if [[ ! -z "$2" ]]; then
		perform 'Clone repo'
		git clone "$1" "$2"
		performed
		
		cd "$2"
		
		perform 'Make sure master branch is checked out'
		git checkout master
		performed
	elif [[ -d "$1" ]]; then
		error 'Unable to instantiate new project, path already exists'
		return
	else
		perform 'Create project folder'
		mkdir -p "$1"
		performed

		cd "$1"
	fi

	deployer_init
	deployer_use
	deployer_local_edit_project

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
	echo 
	gray "Project set to: "
	info "[$(deployer_FolderNameFromPath $project)] >>> $project"
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
	deployer_project_location
	commitMessage="$1"

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
	
	if [[ -z "$commitMessage" ]]; then
		readUser 'Please enter commit message: '
		commitMessage="$input"
	fi

	git commit -m "$input"

    # Add the commit info to the commits.log
    if [[ ! -f "$DEPLOYER_LOCATION"/../logs/project-commits.log ]]; then 
    	touch "$DEPLOYER_LOCATION"/../logs/project-commits.log
   	fi
    formattedCommit="[$(date '+%d-%m-%Y %H:%M:%S')]::[$(deployer_FolderNameFromPath $localProjectLocation)] $input"
    echo $formattedCommit >> "$DEPLOYER_LOCATION"/../logs/project-commits.log

   	echo "$commit"
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
		# Check if there are any changes on branch, if so stash them and re-apply later
		changes=$(git status -s)
		if [[ ! -z $changes ]]; then
			perform_command_local 'Stash current changes' 'git stash' 'Unable to stash changes'
		fi

		perform_command_local "Checkout $1" "git checkout $1" "Unable to checkout branch $1"

		if [[ ! -z $changes ]]; then
			perform_command_local 'Re-apply stashed changes' 'git stash apply' 'Unable to apply stashed changes'
		fi
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
	echo "Project [$folder] >>> $localProjectLocation"
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

function Deployer_project_list() {
	attempt 'show contents of project dir'
	cd $localProjectLocation
	info $(pwd)/"$1"

	if [[ -d $(pwd)/"$1" ]]; then
		if [[ ! -z $1 ]]; then
			ls -la "$1"
		else
			ls -la
		fi
	elif [[ -f $(pwd)/"$1" ]]; then
		cat $(pwd)/"$1"
	else
		error "$(pwd)/$1 not found"
	fi
}