#!/usr/bin/env bash

function deployer_uninstall() {
	attempt "uninstall deployer"
	perform "Remove symlink from bin folder"
	sudo rm /usr/bin/$deployerAlias
	performed
	perform "Remove auxilary file"
	sudo rm "${HOME}/.bashrc_deployer_auxilary"
	performed
	echo 'To re-install, just run init.sh'
}