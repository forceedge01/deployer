#!/usr/bin/env bash

function Deployer_config_edit {
	attempt 'edit project config file'
	$editor $localProjectLocation/$deployerFile
}

function deloyer_config_doctor() {
	# parse the config file and check whats set and whats not
	attempt 'verify the config file'

	if [[ -z $localProjectLocation ]]; then
		error "Local project location not set, please run deployer use in the project directory that holds the $deployerFile file and re-run this command."
		return
	fi

	warning 'SSH Server Settings'

	perform 'SSH server set'
	if [[ -z "$sshServer" ]]; then
		error 'SSH server var not set!'
    else
        performed

		perform 'SSH server reachable'
	    reachable=$(ssh -o BatchMode=yes -o ConnectTimeout=5 $username@$sshServer 'echo 1')
	    if [[ $reachable == 1 ]]; then
	    	performed
	    else
	    	error 'Unable to reach ssh server'
	    fi

	    perform 'Deployer dependencies on server'
	    echo -n 'Git >> '
	    output=$(deployer_ssher 'git --version &>/dev/null && echo -n $?')
	    if [[ $output != 0 ]]; then
	    	error 'Not found'
	    else
	    	performed
	    fi
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
		performed "$repo"
		perform 'Repo Url'
		performed $(Deployer_repo_url)
	fi

	perform 'WebURL'
	if [[ -z $webURL ]]; then
		warning 'Not set'
	else
		performed
	fi

	perform 'logFiles'
	if [[ -z $logFiles ]]; then
		warning "Not set, won't be able to run 'deployer logs'"
	else
		performed
	fi

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

	perform 'Maintenance page'
	if [[ -z $maintenancePageContent ]]; then
		warning 'Maintenance page not set'
	else
		performed
	fi

	perform 'Deployment process'

	if [[ -z $sshServer ]]; then
		warning 'sshServer not set, will not deploy'
		return
	fi

	if [[ ! -z $preDeployCommand ]]; then
		echo
		echo "Pre deploy run -> $preDeployCommand"
	fi

	echo 'Deploy as usual'

	if [[ ! -z $postDeployCommand ]]; then
		perform 'Post deploy run'
		echo "$postDeployCommand"
	fi
}
