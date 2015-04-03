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
		location="$remoteProjectLocation/$configFile"
		result=$(deployer_ssher "[[ -f $location ]] && echo -n $?")	
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
	
	echo $commands
	deployer_run_command 'Alter files with configs specified' "$commands" 'Unable to alter all config files'
}

function getRegexFriendlyString() {
	string="$1"
	declare replacements=("'" '"' '(' ')' ' ' '/' ',' ';')
	for replace in "${replacements[@]}"
	do
		string=${string//$replace/'\'$replace}
	done

	echo "$string"
}

function getAlterCommand() {
	if [[ -z "$1" ]] || [[ -z "$2" ]]; then
		error 'Regex and config must be provided'
		return 1
	fi

	replaceRegex=$(getRegexFriendlyString "$2")
	replaceWith=$(getRegexFriendlyString "$3")

	echo "sed -i'.bk' s/$replaceRegex/$replaceWith/ $1;"
}