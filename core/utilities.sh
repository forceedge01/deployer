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