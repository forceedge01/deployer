#!/usr/bin/env bash

source $localProjectLocation/deployer.config &> /dev/null

function alterConfigFiles() {
	len=${#configFiles[@]}
	if [[ $len == 0 ]]; then
		warning 'No config files specified'
		return 0
	fi

	attempt "Parse config files"
	for configFile in "${configFiles[@]}" 
	do
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
	perform 'Alter files with configs specified'
	echo "$commands"
	# deployer_ssher_toDir "$commands"
	performed
}

function getAlterCommand() {
	if [[ -z "$1" ]] || [[ -z "$2" ]]; then
		error 'Regex and config must be provided'
		return 1
	fi

	echo "sed -i 's/$2/$3/g' $1;"
}