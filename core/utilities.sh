#!/usr/bin/env bash

function attempt() {
	echo "Attempting to $1 on $sshServer..."
}

function perform() {
	echo -n "Performing action -------> $1: "
}

function performed() {
	if [[ -z $1 ]]; then
		echo 'OK'
	else
		echo "$1"
	fi
}

function failed() {
	if [[ -z $1 ]]; then
		echo 'Error'
	else
		echo "$1"
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