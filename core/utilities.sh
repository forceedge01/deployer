#!/usr/bin/env bash

function attempt() {
	yellow "Attempting to $1...\r\n"
}

function perform() {
	blue "Performing action -------> $1: "
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
    read choice;
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
			osascript -e "display notification \"$1\" with title \"Deployer\"";;
		'Linux' )
			notify-send - "$1"
	esac
}