#!/usr/bin/env bash

function deployer_uninstall() {
	attempt "uninstall deployer"
	perform "Remove symlink from bin folder"
	sudo rm /usr/bin/$deployerAlias
	performed
	echo 'To re-install, just run init.sh'
}