#!/usr/bin/env bash

function Deployer_issue_init() {
	warning 'Initialise issues structure'

	if [[ -z $$localProjectLocation ]]; then
		error '$localProjectLocation is not set, please select a project deploy.conf file'
		return
	fi

	perform 'Create empty issues file (safe)'
	touch $localProjectLocation/issues
	performed
}

function Deployer_issue_list() {
	warning 'Display issues'

	if [[ ! -f "$localProjectLocation/issues" ]]; then
		warning "Issues file not found, run 'deployer issue:init' to create one"
		return
	fi

	if [[ ! -z "$1" ]]; then
		cat -n $localProjectLocation/issues | grep "$1"
	else
		cat -n $localProjectLocation/issues
	fi
}

function Deployer_issue_new() {
	warning 'New issue'
	cd $localProjectLocation

	if [[ ! -f ./issues ]]; then
		warning "Issues file not found, run 'deployer issue:init' to create one"
		return
	fi

	if [[ -z "$1" ]]; then
		error 'Must pass issue description'
		return
	fi

	perform 'Add timestamp'
	date=$(date '+%a %d %h %Y %H:%M:%S')
	performed

	perform 'Add user'
	user=$(git config user.name)
	performed

	if [[ ! -z "$3" ]]; then
		category="::[$3]"
	fi

	perform 'Store issue'
	printf "\n[$1]$category --- $date [$user]\n   $2\n" >> ./issues
	performed
}

function Deployer_issue_edit() {
	warning 'About to edit the issues file'
	$editor $localProjectLocation/issues
}