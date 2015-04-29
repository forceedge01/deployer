#!/usr/bin/env bash

function Deployer_version() {
	cd $DEPLOYER_LOCATION && git status | head -n 1
	blue 'Deployer installation folder: '
	echo -n $DEPLOYER_LOCATION
}

function Deployer_update() {
	warning 'Updating deployer...'
	cd $DEPLOYER_LOCATION && git pull origin && git pull origin --tags
	performed
}