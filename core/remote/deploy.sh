#!/usr/bin/env bash
# create the script to be called by the alias i suppose

function deployer_deploy() {
	if [[ -z $repo ]]; then
		error "You need to set the repo variable in the deployer config in order to deploy"
		return
	fi

	if [[ -z "$1" || "$1" == 'master' ]]; then
		branch='latest master'
		attempt "deploy latest from master branch"
	else
		branch="$1"
		attempt "deploy '$1'"
	fi

	if [[ $permissiveDeployment != true ]]; then
		echo -n 'Are you sure you want to continue? [y/n]: '
		answer=$(userChoice)
		if [[ $answer != 'Y' ]]; then
			return 1
		fi
		echo
	fi

	fileResult=''
	if [[ ! -z $maintenancePageContent ]]; then
		fileResult=$(deployer_ssher_toDir 'ls' | grep ^index.html$)
		if [[ -z $fileResult ]]; then
			deployer_run_command 'Put up maintenance page' "touch index.html && echo '$maintenancePageContent' > index.html"
		else 
			error 'Unable to setup maintenance page, file already exists'
		fi
	fi

	info "Updating path: $remoteProjectLocation"

	deployer_preDeploy
	# this is a special variable used by the deployer_run_command, it will set it to 0 if the command was successful
	success=1
	
	if [[ -z "$1" || "$1" == 'master' ]]; then
		deployer_run_command "Updating remote 'master'" "git checkout . && git checkout $1 &> /dev/null && git pull origin $1" 'Unable to update'
	else
		deployer_run_command 'Update remote server' 'git fetch --tags; git fetch origin' 'Unable to get tags'
		deployer_run_command "Checkout tag/branch '$1'" "git checkout $1" 'Unable to checkout branch'
		deployer_run_command 'Update remote server codebase if needed' "[[ $(git describe --exact-match HEAD &>/dev/null; echo $?) != 0 ]] && git pull origin $1" 'Not needed'
	fi

	alterConfigFiles
	deployer_postDeploy

	if [[ ! -z $maintenancePageContent ]]; then
		if [[ -z $fileResult ]]; then
			deployer_run_command 'Take down maintenance page' 'rm index.html'
		fi
	fi

	depolyer_remote_project_status
	if [[ $success == 0 ]]; then
		deployer_os_notification "$branch deployed successfully"
	else
		deployer_os_notification "Unable to deploy $branch"
	fi
}

function deployer_pull_changes() {
	echo $(deployer_run_command "Updating remote '$1'" "git checkout . && git checkout $1 &> /dev/null && git pull origin $1" 'Unable to update')
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

	success=1
	
	deployer_run_command "Deploy tag $latestTag" "git checkout $latestTag" "Unable to checkout $latestTag"
	# perform "Deploy tag $latestTag"
	# deployer_ssher_toDir "git checkout $latestTag"
	# performed
	alterConfigFiles
	deployer_postDeploy
	depolyer_remote_project_status

	if [[ $success == 0 ]]; then
		deployer_os_notification "Latest tag deployed successfully"
	else
		deployer_os_notification "Unable to deploy"
	fi
}

function deployer_preDeploy() {
	warning 'Pre-deploy: check for dependencies'

	deployer_check_depenedencies_remote

	if [[ ! -z $preDeployCommand ]]; then
		performed 'Pre-deploy commands'
		deployer_run_semicolon_delimited_commands "$preDeployCommand" true true
		performed 'End of pre-deploy commands'
	fi
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

function deployer_check_depenedencies_remote()
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
			output=$(deployer_ssher "$cmd")

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

function deployer_postDeploy() {
	if [[ ! -z $postDeployCommand ]]; then
		performed 'Post-deploy commands'
		deployer_run_semicolon_delimited_commands "$postDeployCommand" true true
		performed 'End of post-deploy commands'
	fi
}

function deployer_remote_init() {
	attempt "setup project"
	deployer_run_command 'Clone repo on remote server' "mkdir -p $remoteProjectLocation && git clone $repo $remoteProjectLocation && cd $remoteProjectLocation/" 'Something went wrong, please try again'
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
