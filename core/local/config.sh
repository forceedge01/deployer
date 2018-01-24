#!/usr/bin/env bash

function Deployer_config_edit {
	attempt 'edit project config file'
	$editor $localProjectLocation/$deployerFile
}

function deployer_check_depenedencies_local() 
{
	if [[ -z $dependencies ]]; then
		info 'No dependencies specified'
	else
		for dependency in "${dependencies[@]}"
		do
			perform 'Check '$dependency
			# Split based on '='
			IFS='=' read -ra ADDR <<< "$dependency"
			
			# Check if '=' was provided, if not just check if the binary exists
			if [[ -z ${ADDR[1]} ]]; then
				cmd="command -v ${ADDR[0]}"
			else	
				cmd="${ADDR[0]} --version"
			fi

			# Run command on remote server
			output=$($cmd)

			if [[ ! -z "${ADDR[1]}" ]]; then
				check=$(echo "$output" | grep ${ADDR[1]})
			else
				# output empty means that the binary was not found
				check=$output
			fi
		    
		    # Check output of command
		    # Output empty means binary not found
		    if [[ -z $check ]]; then
		    	error "Not found, output from server: $output"
		    else
		    	performed
		    fi
		done
	fi
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

    warning 'Checking local environment dependencies'
    deployer_check_depenedencies_local
    
    warning 'Checking remote environment dependencies'
    deployer_check_depenedencies_remote

	warning 'SSH debug Settings'

	perform 'verbosity'
	[[ ! -z $verbose ]] && echo $verbose || echo "false"

	warning 'App specific settings'

	perform 'Push to remote channel: '
	performed "$remote (git push $remote)"

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

	perform 'dev command'
	if [[ -z $devStart ]]; then
		warning 'No dev command, nullified project:dev'
	else
		if [[ $(echo "$devStart" | grep ';') == '' ]]; then
			error "Command must end with semicolon: '$devStart' -> '$devStart;'"
		else
			performed "$devStart"
		fi
	fi

	perform 'test command'
	if [[ -z $testStart ]]; then
		warning 'No test command, nullified project:test'
	else
		if [[ $(echo "$testStart" | grep ';') == '' ]]; then
			error "Command must end with semicolon: '$testStart' -> '$testStart;'"
		else
			performed "$testStart"
		fi
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
