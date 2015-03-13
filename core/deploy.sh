#!/usr/bin/env bash
# create the script to be called by the alias i suppose

function deployer_deploy() {
	if [[ -z "$1" ]]; then
		attempt "deploy latest from master branch"
		if [[ $permissiveDeployment != true ]]; then
			echo -n 'Are you sure you want to continue? [y/n]: '
			answer=$(userChoice)
			if [[ $answer != 'Y' ]]; then
				return 1
			fi
		fi

		deployer_preDeploy
		perform "pull latest commit from master branch"
		deployer_ssher_toDir "git checkout . && git checkout master &> /dev/null && git pull origin master"
		performed
	else
		attempt "deploy '$1'"
		if [[ $permissiveDeployment != true ]]; then
			echo -n 'Are you sure you want to continue? [y/n]: '
			answer=$(userChoice)
			if [[ $answer != 'Y' ]]; then
				return 1
			fi
		fi

		deployer_preDeploy
		deployer_remote_update
		perform "Checkout tag '$1'"
		deployer_ssher_toDir "git checkout $1"
		performed
	fi
	alterConfigFiles
	deployer_postDeploy
	depolyer_remote_project_status
}

function deployer_deploy_latest() {
	attempt "Deploy latest tag"
	if [[ $permissiveDeployment != true ]]; then
		echo -n 'Are you sure you want to continue? [y/n]: '
		answer=$(userChoice)
		if [[ $answer != 'Y' ]]; then
			return 1
		fi
	fi

	deployer_preDeploy
	perform "Fetch latest tag"
	cd $localProjectLocation
	latestTag=$(git fetch && git describe --tags `git rev-list --tags --max-count=1`)

	if [[ -z $latestTag ]]; then
		failed "No tag available"
		return 0
	fi

	performed "$latestTag"
	deployer_remote_update
	perform "Deploy tag $latestTag"
	deployer_ssher_toDir "git checkout $latestTag"
	performed
	deployer_postDeploy
	depolyer_remote_project_status
}

function deployer_preDeploy() {
	if [[ ! -z $preDeployCommand ]]; then
		perform 'Run pre-deploy commands: '
		deployer_ssher_toDir "$preDeployCommand"
	fi
}

function deployer_postDeploy() {
	if [[ ! -z $postDeployCommand ]]; then
		perform 'Run post-deploy commands: '
		deployer_ssher_toDir "$postDeployCommand"
	fi
}

function deployer_remote_init() {
	attempt "setup project"
	perform "Clone repo on remote server"
	deployer_ssher_toDir "mkdir -p $remoteProjectLocation && git clone $repo $remoteProjectLocation && cd $remoteProjectLocation/"
	performed
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

	perform "Re-clone repo on remote server"
	deployer_ssher_toDir "rm -rf $remoteProjectLocation && mkdir -p $remoteProjectLocation && git clone $repo $remoteProjectLocation && cd $remoteProjectLocation/; git remote add origin $repo"
	performed
}

function deployer_remote_update() {
	attempt "update"
	perform "Updating remote server"
	deployer_ssher_toDir "git fetch; git fetch origin --tags"
	performed
}

function deployer_remote_tags() {
	attempt "fetch tags from remote machine"
	perform "fetch tags"
	deployer_ssher_toDir "git fetch --tags; git tag"
	performed
}

function deployer_remote_status() {
	perform "Ram status"
	echo
	deployer_ssher "free -m"
	echo
	perform "apache status"
	deployer_ssher "sudo service httpd status"
	echo
	perform "mysql status"
	deployer_ssher "sudo service mysqld status"
	echo
	depolyer_remote_project_status
}

function depolyer_remote_project_status() {
	perform "remote status"
	deployer_ssher "cd $remoteProjectLocation; git status | head -n 1"
}

function deployer_remote_get() {
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