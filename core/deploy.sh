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
	deployer_postDeploy
	depolyer_remote_project_status
}

function deployer_remote_download() {
	if [[ -z "$1" ]]; then
		attempt "list downloads directory: '$downloadsPath'"
		deployer_ssher_toDir "ls -la $downloadsPath | sed 2,3d"
		return 0
	fi
	attempt "download file from '$1'"
	perform 'Check if the download url is valid'
	header=$(curl -sI $1)
	length=$(echo "$header" | grep 'Content-Length' | awk '{split($0,chunks," "); print chunks[2]}' | xargs)
	status=$(echo "$header" | grep 'HTTP/1.1' | awk '{split($0,chunks," "); print chunks[2]}' | xargs)
	if [[ $length < 1 ]] || [[ $status =~ ^4|5\d{2}$ ]]; then
		error 'The download link is invalid'
		return
	fi
	performed
	perform "Make sure '$downloadsPath' exists"
	deployer_ssher "mkdir -p $downloadsPath"
	performed
	perform 'Download and show file'
	echo
	deployer_ssher_toDir "cd $downloadsPath && curl -#OL '$1'; ls -la | sed 2,3d"
}

function deployer_local_upload() {
	if [[ -z "$1" ]]; then
		attempt "list uploads directory: '$uploadsPath'"
		deployer_ssher "ls -la $uploadsPath | sed 2,3d"
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
	perform "remote project version"
	deployer_ssher "cd $remoteProjectLocation; git describe"
	performed
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