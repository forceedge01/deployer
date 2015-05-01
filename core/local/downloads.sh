#!/usr/bin/env bash

Deployer_downloads_list() {
	warning 'List all downloads'

	if [[ ! -d "$localProjectLocation/$downloadsFolder" ]]; then
		error 'Downloads folder not found'
		return
	fi

	ls -la "$localProjectLocation/$downloadsFolder";
}

Deployer_downloads_open() {
	warning "Open file $1"
	
	if [[ ! -d "" ]]; then
		error 'Downloads folder not found'
		return
	fi

	open "$localProjectLocation/$downloadsFolder/$1"
}

Deployer_downloads_get() {
	warning 'Download file to local downloads'

	cd "$localProjectLocation"
	perform_command_local 'Make sure the downloads folder for project exists' 'mkdir $downloadsFolder' 'Unable to create downloads folder'
	perform_command_local 'Download file' "cd $localProjectLocation/$downloadsFolder && curl -O# $1" 'Unable to download file'
}