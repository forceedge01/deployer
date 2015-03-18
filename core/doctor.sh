#!/usr/bin/env bash

function deloyer_doctor() {
	# check if deployer files are all there
	# check if remote is set then remote is cloned
	# check if remote is set remote has origin
	# check if local is set then local is present
	# check if local is set then the config file exists
	# check if ssh server is set then server is sshable
	echo ''
}

function deployer_config_status() {
	# parse the config file and check whats set and whats not
	attempt 'check the config file'

	warning 'SSH Server Settings'

	perform 'SSH server set'
	if [[ -z "$sshServer" ]]; then
		error 'SSH server var not set!'
    else
        performed
    fi

	perform 'username for SSH server set'
	if [[ -z "$username" ]]; then
		error 'username var not set!'
    else
	    performed
    fi

	warning 'SSH debug Settings'

	perform 'verbosity'
	[[ ! -z $verbose ]] && echo $verbose || echo "false"

	warning 'Deployment settings'

	perform "Deployment method"
	if [[ $deploymentMethod != 'git' ]]; then
		error "unsupported method $deploymentMethod"
	else
		performed
	fi

	perform 'Permissive deployments'
	[[ ! -z $permissiveDeployment ]] && echo $permissiveDeployment || echo "false"
	perform 'Downloads path'
	if [[ -z $downloadsPath ]]; then
		warning 'Not set, Wont be able to download files'
	else
		performed
	fi

	perform 'Uploads path'
	if [[ -z $uploadsPath ]]; then
		warning 'Not set, Wont be able to upload files'
	else
		performed
	fi

	warning 'App specific settings'

	perform 'Remote project location'
	if [[ -z $remoteProjectLocation ]]; then
		warning 'Not set, using home dir'
	else
		performed
	fi

	perform 'Repo location'
	if [[ -z $repo ]]; then
		error 'Not set, unable to deploy'
	else
		performed
	fi

	perform 'WebURL'
	if [[ -z $webURL ]]; then
		warning 'Not set'
	else
		performed
	fi

	perform 'Deployment process'
	if [[ ! -z $preDeployCommand ]]; then
		echo
		echo "Pre deploy run -> $preDeployCommand"
	fi

	echo 'Deploy as usual'

	if [[ ! -z $postDeployCommand ]]; then
		echo "Post deploy run -> $postDeployCommand"
	fi
	performed 'Done'
}
