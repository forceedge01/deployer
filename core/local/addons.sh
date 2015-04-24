#!/usr/bin/env bash

function Deployer_addons_get() {
	warning 'Add addon'
	perform "Add addon '"$(getFolderNameFromRepoUrl)"'"
	if [[ -d $DEPLOYER_LOCATION/../addons/$(getFolderNameFromRepoUrl) ]]; then
		error 'Addon already exists, please remove before trying again.'

		return
	fi

	git clone "$1" $DEPLOYER_LOCATION/../addons/$(getFolderNameFromRepoUrl)
	performed
}

function Deployer_addons_remove() {
	warning 'Remove an addon'
	perform "Remove addon '$1'"
	if [[ ! -d $DEPLOYER_LOCATION/../addons/"$1" ]]; then
		error 'Addon not found, please make sure it exists.'
	fi

	rm -rf $DEPLOYER_LOCATION/../addons/"$1"
	performed
}

function Deployer_addons_list() {
	warning 'List all addons'
	for i in $DEPLOYER_LOCATION/../addons/*
	do
		IFS='/' read -ra chunks <<< "$i"
		length=$((${#chunks[@]}-1))
		echo "${chunks[$length]}"
	done
}