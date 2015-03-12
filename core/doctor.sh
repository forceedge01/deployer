#!/usr/bin/env bash

function deloyer_doctor() {
	# check if deployer files are all there
	# check if remote is set then remote is cloned
	# check if remote is set remote has origin
	# check if local is set then local is present
	# check if local is set then the config file exists
	# check if ssh server is set then server is sshable
}

function deployer_config_status() {
	# parse the config file and check whats set and whats not
	attempt 'check the config file'
	perform 'ssh server set'
	if [[ -z "$sshServer" ]]; then
		warning 'sshServer var not set!'
	fi
	performed

	perform 'username for ssh server set'
	if [[ -z "$username" ]]; then
		warning 'username var not set!'
	fi
	performed

	perform 'ssh server set'
	if [[ -z "$sshServer" ]]; then
		warning 'sshServer var not set!'
	fi
	performed

	perform 'ssh server set'
	if [[ -z "$sshServer" ]]; then
		warning 'sshServer var not set!'
	fi
	performed
# connect to SSH server as
declare username=''

# ---------------------------------------------–------- #

# SSH settings
# set the verbositiy of the deployment process
declare verbose=0

# ---------------------------------------------–------- #

# deploy settings
# services to check for after deployment
declare services=(httpd mysqld)
# deploy using git or scp
declare deploymentMethod='git'
# command to run before deployment starts, by default runs in the project directory
declare preDeployCommand=''
# command to run after deployment is done, by default runs in the project directory
declare postDeployCommand=''
# do not ask for confirmation before deployment
declare permissiveDeployment=false
# set downloads folder for deployer
declare downloadsPath='~/deployer_downloads'
# set uploads folder for deployer
declare uploadsPath='~/deployer_uploads'

# ---------------------------------------------–------- #

# app specific settings
declare editor='vim'
# project location on SSH server
declare remoteProjectLocation=''
# project repo url
declare repo=''
# project web url, is used with open command
declare webURL=''
# change config file params
declare configFiles=()
# changes to make in config file specified, i.e ('regex' 'value')
declare config=()

# ---------------------------------------------–------- #
	
}