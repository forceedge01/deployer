#!/usr/bin/env bash

function attempt() {
	yellow "Attempting to $1...\r\n"
}

function perform() {
	gray "Perform >> $1: "
}

function performed() {
	if [[ -z $1 ]]; then
		green "OK\r\n"
	else
		green "$1\r\n"
	fi
}

function failed() {
	if [[ -z $1 ]]; then
		red "Error\r\n"
	else
		red "$1\r\n"
	fi
}

function argRequired() {
	if [[ -z $1 ]]; then
		echo "Argument is required for this call. $2"
		return 0
	fi

	return 1
}

function red()
{
	printf "\e[31m$1\e[0m"
}

function blue()
{
	printf "\e[36m$1\e[0m"
}

function green()
{
	printf "\e[32m$1\e[0m"	
}

function yellow()
{
	printf "\e[33m$1\e[0m"
}

function gray() {
	printf "\e[38;5;243m$1\e[0m"
}

function error()
{
	red "$1\n"
}

function warning()
{
	yellow "$1\n"
}

function info()
{
	blue "$1\n"
}

function success()
{
	green "$1\n"
}

function fandiOpen() {
	open "$1";
}

function readUser()
{
	unset input

	while [ -z "$input" ]; do
		printForRead "$1";
		read input;
	done

	eval $(input="$input")
}

function userChoice () {
    unset choice;
    read -d'' -s -n1 choice
    case $choice in
      "n"|"N" ) echo 'N';;
      "y"|"Y" ) echo 'Y';;
      *) echo 'Response not valid';;
    esac
}

function printForRead () {
  printf "\n** $1";
}

function deployer_os_notification() {
	platform=$(echo `uname`)
	case "$platform" in 
		'Darwin' )
			osascript -e "display notification \"$1\" with title \"Deployer: $sshServer\"";;
		'Linux' )
			notify-send "Deployer" "$1"
	esac
}

function deployer_run_command() {
	perform "$1"
	if [[ $verbose == 1 ]]; then
		deployer_ssher_toDir "$2"
		return 0
	fi
	if [[ $3 == 1 ]]; then
		deployer_ssher_toDir "$2"
		return 0
	fi

	result=$(deployer_ssher_toDir "($2) &>/dev/null && echo -n $?")
	if [[ $result == 0 ]]; then
		performed
	else
		error "$3"
	fi
}

function deployer_exec() {
	"$1"
	if [[ $? != 0 ]]; then
		echo $?
	fi
}

function getCurrentBranchName() {
	git rev-parse --abbrev-ref HEAD
}

function getFolderNameFromRepoUrl() {
	IFS='/' read -ra ADDR <<< "$repo"
	for fragment in "${ADDR[@]}" 
	do
		frag="$fragment"
	done

	echo "$frag"
}

function deployer_FolderNameFromPath() {
	IFS='/' read -ra ADDR <<< "$1"
	for fragment in "${ADDR[@]}" 
	do
		frag="$fragment"
	done

	echo "$frag"
}

function Deployer_repo_url() {
	substring=$(echo $repo | grep http)
	if [[ -z $substring ]]; then # is a ssh url e.g git@bitbucket.org:wqureshi/driving-theory-test-project.git
		# explode on @, then on : and trim .git
		IFS='@' read -ra ADDR <<< "$repo"
		IFS=':' read -ra ADDR <<< "${ADDR[1]}"
		url="https://${ADDR[0]}/${ADDR[1]}"
	else # is a http url e.g https://wqureshi@bitbucket.org/wqureshi/driving-theory-test-project.git
		# remote everything before @ sign and trim .git
		IFS='@' read -ra ADDR <<< "$repo"
		url='https://'${ADDR[1]}
	fi
	
	echo "$url"
}

function deployer_run_semicolon_delimited_commands() {
	if [[ $(echo "$1" | grep ';') == '' ]]; then
		error 'Command must end with semicolon'
		return
	fi

	breakOnFailure=$2

	IFS=';' read -ra ADDR <<< "$1"
	for command in "${ADDR[@]}" 
	do
		perform "$command"
		$command
		if [[ $? != 0 ]]; then
			error 'An error occured'

			if [[ $breakOnFailure == true ]]; then
				return
			fi
		else
			performed "$command"
		fi
	done
}

function perform_command_local() {
	perform "$1"
	exitCode=$($2 &>/dev/null && echo -n $?)
	if [[ $exitCode != 0 ]]; then
		error "$3"
		return
	fi
	performed
}

function yesterday() {
	date -v-1d '+%d-%m-%Y'
}