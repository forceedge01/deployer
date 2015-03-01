#!/usr/bin/env bash
# create the script to be called by the alias i suppose

source $DEPLOYER_LOCATION/ssher.sh
source $DEPLOYER_LOCATION/utilities.sh

function deployer_deploy() {
	attempt "pull the latest"
	perform "pull latest master branch"
	deployer_ssher_toDir "git pull origin master"
	performed
}

function deployer_init() {
	attempt "setup project"
	perform "Clone repo on remote server"
	deployer_ssher_toDir "mkdir -p $remoteProjectLocation; cd $remoteProjectLocation/..; git clone $repo"
	performed
}

function deployer_remote_update() {
	attempt "update"
	perform "Updating remote server"
	deployer_ssher_toDir "git fetch; git fetch --tags"
	performed
}

function deployer_remote_tags() {
	attempt "fetch tags from remote machine"
	perform "fetch tags"
	deployer_ssher_toDir "git fetch --tags; git tag"
	performed
}

function deployer_deploy_latest() {
	attempt "Deploy latest tag"
	perform "Fetch latest tag"
	latestTag=$(git fetch; git describe --tags `git rev-list --tags --max-count=1`)

	if [[ -z $latestTag ]]; then
		failed "No tag available"
		return 0
	fi

	performed "$latestTag"
	perform "Update remote server"
	deployer_remote_update
	performed
	perform "Deploy tag $latestTag"
	deployer_ssher_toDir "git checkout $latestTag"
	performed
}

function deployer_deploy_tag() {
	attempt "deploy"
	if [[ -z $1 ]]; then
		failed 'You must specify a tag';
	else
		perform "Checkout tag '$1'"
		deployer_ssher_toDir "git fetch --tags; git checkout $1"
		performed
	fi
}