#!/usr/bin/env bash

# example command deployer push, deployer push latest, deployer push v or hash, deployer remote update, deployer update, deployer init
function helperMenu() {
	deployMenu
}

function deployMenu() {
	echo 'Deploy menu'
	printMenu "init" "Initialize repository on ssh server"
	printMenu "ssh" "log into ssh machine"
	printMenu "ssh [arg]" "ssh commands over to ssh server"
	printMenu "sshp [arg]" "ssh commands over to ssh server on the project directory"
	printMenu "deploy" "Deploy latest master branch on remote server"
	printMenu "deploy [branch/commit/tag]" "deploy a branch, version or commit to the remote server"
	printMenu "remote update" "update remote server"
	printMenu "remote tags" "view tags available on remote machine"
	printMenu "config" "View the config file for deployer"
	printMenu "config edit" "edit the config file for deployer"
	printMenu "update" "update deployer"
}

function printMenu() {
	echo '-------------------------------------------'
	echo "$1              $2"
}