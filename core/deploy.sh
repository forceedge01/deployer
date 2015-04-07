#!/usr/bin/env bash
# create the script to be called by the alias i suppose

function deployer_deploy() {
	if [[ -z $repo ]]; then
		error "You need to set the repo variable in the deployer config in order to deploy"
		return
	fi

	if [[ -z "$1" ]]; then
		branch='latest master'
		attempt "deploy latest from master branch"
		if [[ $permissiveDeployment != true ]]; then
			echo -n 'Are you sure you want to continue? [y/n]: '
			answer=$(userChoice)
			if [[ $answer != 'Y' ]]; then
				return 1
			fi
			echo
		fi

		deployer_preDeploy
		deployer_pull_changes "master"
	else
		branch="$1"
		attempt "deploy '$1'"
		if [[ $permissiveDeployment != true ]]; then
			echo -n 'Are you sure you want to continue? [y/n]: '
			answer=$(userChoice)
			if [[ $answer != 'Y' ]]; then
				return 1
			fi
			echo
		fi

		deployer_preDeploy
		deployer_run_command 'Update remote server' 'git fetch --tags; git fetch origin' 'Unable to get tags'
		deployer_run_command "Checkout tag/branch '$1'" "git checkout $1" 'Unable to checkout branch'
		deployer_run_command 'Update remote server codebase if needed' "[[ $(git describe --exact-match HEAD &>/dev/null; echo $?) != 0 ]] && git pull origin $1" 'Not needed'
	fi
	alterConfigFiles
	deployer_postDeploy
	depolyer_remote_project_status
	deployer_os_notification "$branch deployed successfully"
}

function deployer_pull_changes() {
	deployer_run_command "Updating remote '$1'" "git checkout . && git checkout $1 &> /dev/null && git pull origin $1" 'Unable to udpate'
	# perform "Updating remote: $1"
	# result=$(deployer_ssher_toDir "git checkout . && git checkout $1 &> /dev/null && git pull origin $1 &>/dev/null && [[ $(echo $?) == 0 ]] && echo 0")
	# if [[ $result == 0 ]]; then
	# 	performed
	# 	return
	# fi
	# error 'Unable to update'
}

function deployer_deploy_latest() {
	if [[ -z $repo ]]; then
		error "You need to set the repo variable in the deployer config in order to deploy"
		return
	fi
	
	attempt "Deploy latest tag"
	if [[ $permissiveDeployment != true ]]; then
		echo -n 'Are you sure you want to continue? [y/n]: '
		answer=$(userChoice)
		if [[ $answer != 'Y' ]]; then
			return 1
		fi
		echo
	fi

	deployer_preDeploy
	perform "Fetch latest tag"
	cd $localProjectLocation
	latestTag=$(git fetch && git describe --abbrev=0 --tags 2> /dev/null)

	if [[ -z $latestTag ]]; then
		error "No tag available"
		return 0
	fi

	performed "$latestTag"
	deployer_remote_update
	deployer_run_command "Deploy tag $latestTag" "git checkout $latestTag" "Unable to checkout $latestTag"
	# perform "Deploy tag $latestTag"
	# deployer_ssher_toDir "git checkout $latestTag"
	# performed
	alterConfigFiles
	deployer_postDeploy
	depolyer_remote_project_status
	deployer_os_notification "Latest tag deployed successfully"
}

function deployer_preDeploy() {
	if [[ ! -z $preDeployCommand ]]; then
		deployer_run_command 'Run pre-deploy commands' "$preDeployCommand" 'Unable to run preDeployCommands'
		# perform 'Run pre-deploy commands: '
		# deployer_ssher_toDir "$preDeployCommand"
	fi
}

function deployer_postDeploy() {
	if [[ ! -z $postDeployCommand ]]; then
		deployer_run_command 'Run post-deploy commands' "$postDeployCommand" 'Unable to run postDeployCommands'
		# perform 'Run post-deploy commands: '
		# deployer_ssher_toDir "$postDeployCommand"
	fi
}

function deployer_remote_init() {
	attempt "setup project"
	deployer_run_command 'Clone repo on remote server' "mkdir -p $remoteProjectLocation && git clone $repo $remoteProjectLocation && cd $remoteProjectLocation/" 'Something wentwrong, please try again'
	# perform "Clone repo on remote server"
	# deployer_ssher_toDir "mkdir -p $remoteProjectLocation && git clone $repo $remoteProjectLocation && cd $remoteProjectLocation/"
	# performed
	alterConfigFiles
}

function deployer_reclone() {
	attempt "re-setup project"
	if [[ $permissiveDeployment != true ]]; then
		echo -n 'This will remove existing files and re-create them, are you sure you want to continue? [y/n]: '
		answer=$(userChoice)
		if [[ $answer != 'Y' ]]; then
			return 1
		fi
	fi

	deployer_run_command 'Re-clone repo on remote server' "rm -rf $remoteProjectLocation && mkdir -p $remoteProjectLocation && git clone $repo $remoteProjectLocation && cd $remoteProjectLocation/; git remote add origin $repo" 'Unable to re-clone, please try again'
	# perform "Re-clone repo on remote server"
	# deployer_ssher_toDir "rm -rf $remoteProjectLocation && mkdir -p $remoteProjectLocation && git clone $repo $remoteProjectLocation && cd $remoteProjectLocation/; git remote add origin $repo"
	# performed
	alterConfigFiles
}

function deployer_remote_update() {
	attempt "update"
	deployer_run_command 'Updating remote server' 'git fetch; git fetch origin --tags' 'Unable to update'
	# perform "Updating remote server"
	# deployer_ssher_toDir "git fetch; git fetch origin --tags"
	# performed
}

function deployer_remote_tags() {
	attempt "fetch tags from remote machine"
	perform "fetch tags"
	deployer_ssher_toDir "git fetch --tags; git tag"
	performed
}

function depolyer_remote_project_status() {
    deployer_run_command 'Remote status' "cd $remoteProjectLocation; git status | head -n 1" 1
}

function deployer_remote_get() {
	if [[ -z "$1" ]]; then
		error 'Path must be specified'
		return
	fi
	attempt "get '$1' from remote server"
	perform "Get file from remote server"
	file="${1// /\ }"
	scp -r "$username@$sshServer:$file" "./" 2> /dev/null
	if [[ $(echo $?) != 0 ]]; then
		error 'file not found!'
		return
	fi
	performed
}

function deployer_open_web() {
	if [[ ! -z "$webURL" ]]; then 
		open $webURL
	else 
		error "Value for 'webURL' not specified in config" 
	fi
}
