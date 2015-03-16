#!/usr/bin/env bash

source $localProjectLocation/deployer.config &> /dev/null

function alterConfigFiles() {
	perform 'Edit config files'
	len=${#configFiles[@]}
	if [[ $len == 0 ]]; then
		warning 'No config files specified'
		return 0
	fi

	attempt "Parse config files"
	for configFile in "${configFiles[@]}" 
	do
		perform "Make sure the file '$configFile' exists"
		result=$(deployer sshp "if [[ -f $configFile ]]; then echo 0; else echo 1; fi")
		if [[ $result != 0 ]]; then
			error 'Not found!'
			continue
		else
			performed
		fi

		for (( i=0; i<=(( ${#config[@]} - 1 )); i=((i+2)) ))
		do
			if [[ $((i % 2)) == 0 ]]; then
				regex=${config[$i]}
				replacement=${config[$((i+1))]}
				stringReplace=$(getAlterCommand "$configFile" "$regex" "$replacement")
				commands="$commands $stringReplace"
			fi
		done
	done

	if [[ -z $commands ]]; then
		return 0
	fi
	
	deployer_run_command 'Alter files with configs specified' "$commands" 'Unable to alter all config files'
	# perform 'Alter files with configs specified'
	# deployer_ssher_toDir "$commands"
	# performed
}

function getAlterCommand() {
	if [[ -z "$1" ]] || [[ -z "$2" ]]; then
		error 'Regex and config must be provided'
		return 1
	fi

	echo "sed -i '.bk' 's/$2/$3/' $1;"
}