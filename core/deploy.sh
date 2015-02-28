#!/usr/bin/env bash
# create the script to be called by the alias i suppose

source ssher.sh

function deploy() {
	attempt "pull the latest"
	perform "pull latest master branch"
	ssher_toDir "git pull origin master"
	performed
}

function init() {
	attempt "setup project"
	perform "Clone repo on remote server"
	ssher_toDir "mkdir -p $remoteProjectLocation; cd $remoteProjectLocation/..; git clone $repo"
	performed
}

function remote_update() {
	attempt "update"
	perform "Updating remote server"
	ssher_toDir "git fetch; git fetch --tags"
	performed
}

function deploy_latest() {
	attempt "Deploy latest tag"
	perform "Fetch latest tag"
	latestTag=$(git fetch; git describe --tags `git rev-list --tags --max-count=1`)

	if [[ -z $latestTag ]]; then
		failed "No tag available"
		return 0
	fi

	performed "$latestTag"
	perform "Update remote server"
	remote_update()
	performed
	perform "Deploy tag $latestTag"
	ssher_toDir "git checkout $latestTag"
	performed
}

function deploy_tag() {
	attempt "deploy"
	if [[ -z $1 ]]; then
		failed 'You must specify a tag';
	else
		perform "Checkout tag '$1'"
		ssher_toDir "git fetch --tags; git checkout $1"
		performed
	fi
}

function attempt() {
	echo "Attempting to $1 on $sshServer..."
}

function perform() {
	echo -n "Performing action -----> $1: "
}

function performed() {
	if [[ -z $1 ]]; then
		echo 'OK'
	else
		echo "$1"
	fi
}

function failed() {
	if [[ -z $1 ]]; then
		echo 'Error'
	else
		echo "$1"
	fi
}