#!/usr/bin/env bash
#!/usr/bin/env bash

# example command deployer push, deployer push latest, deployer push v or hash, deployer remote update, deployer update, deployer init
function helperMenu() {
	deployMenu
}

function deployMenu() {
	echo 'Deployer menu'
	printMenu "ssh" "log into ssh machine"
	printMenu "ssh [arg]" "ssh commands over to ssh server"
	printMenu "sshp [arg]" "ssh commands over to ssh server on the project directory"
	printMenu "deploy | d" "Deploy latest master branch on remote server"
	printMenu "deploy [branch/commit/tag]" "deploy a branch, version or commit to the remote server"
	printMenu "remote" "Show remote project version"
	printMenu "remote init | clone" "Initialize repository on ssh server"
	printMenu "remote reclone" "Re-Initialize repository on ssh server"
	printMenu "remote update" "update remote server"
	printMenu "remote tags" "view tags available on remote machine"
	printMenu "remote status" "show status of remote machine"
	printMenu "config" "View the config file for deployer"
	printMenu "config edit" "edit the config file for deployer"
	printMenu "update" "update deployer"
	printMenu "open | web" "Open project link in browser"
	printMenu "version | v" "Deisplay deployer version"
	printMenu "uninstall" "uninstall deployer"
}

function printMenu() {
	echo '-------------------------------------------'
	echo "$1              $2"
}