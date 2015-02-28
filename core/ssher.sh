#!/usr/bin/env bash

source ../config/main.sh

function ssher() {
	ssh $username@$sshServer "$1"
}

function ssher_toDir() {
	ssher "cd cd $remoteProjectLocation; $1" &> /devl/null
}