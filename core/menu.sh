#!/usr/bin/env bash
#!/usr/bin/env bash

# example command deployer push, deployer push latest, deployer push v or hash, deployer remote update, deployer update, deployer init
function helperMenu() {
	deployMenu
}

function deployMenu() {
	warning 'Deployer menu'
	printMenu 'init' 'Create deployer.config file for current directory'
	printMenu 'use' 'Use the current directories deployer.config file for deployer'
	printMenu "ssh [arg]" "log into ssh machine or run command on remote machine"
	printMenu "sshp [arg]" "ssh commands over to ssh server on the project directory"
	printMenu "deploy | d" "Deploy latest master branch on remote server"
	printSubMenu "[branch/commit/tag]" "deploy a branch, version or commit to the remote server"
	printMenu "config" "View the config file for deployer"
	printSubMenu "edit" "edit the config file for deployer"
	printSubMenu "verify" "verify the config file"
	printMenu 'project | p [arg]' 'Show project location or run command on project location'
	printSubMenu "open | web | w" "Open project link in browser"
	printSubMenu 'edit | e' 'Edit current project in configured editor'
	printSubMenu 'update | u' 'Update current project locally'
	printSubMenu 'save | s' 'Save local project changes'
	printMenu "remote | r" "Show remote project version"
	printSubMenu "init | clone" "Initialize repository on ssh server"
	printSubMenu "reclone" "Re-Initialize repository on ssh server"
	printSubMenu "update" "update remote server"
	printSubMenu "tags" "view tags available on remote machine"
	printSubMenu "status" "show status of remote machine"
	printSubMenu "upload [arg]" "upload file/folder to ssh server's configured uploads directory"
	printSubMenu "download [arg]" "download file/folder to ssh server's configured downloads directory"
	printSubMenu 'get [file/folderPath]' 'Get a file/folder from the remote server'
	printSubMenu 'services status' 'status of all configured services on remote machine'
	printSubMenu 'services start' 'start services configured on remote machine'
	printSubMenu 'services restart' 'restart services configured on remote machine'
	printSubMenu 'service status [service]' 'status single custom service'
	printSubMenu 'service start [service]' 'start single custom service'
	printSubMenu 'service stop [service]' 'stop single custom service'
	printSubMenu 'service restart [service]' 'restart single custom service'
	printMenu 'dev' 'Run devStart command configured in config file'
	printMenu "update | u" "Update deployer"
	printMenu "version | v" "Display deployer version"
	printMenu "uninstall" "uninstall deployer"
}

function printMenu() {
	firstColumnCount=35
	argSize=${#1}
	spaces=$((firstColumnCount-$argSize))
	
	echo 
	echo -n "$1"
	while [ $spaces -gt 0 ]; do
		echo -n ' '
		spaces=$((spaces-1))
	done
	echo "$2"
	while [ $argSize -gt 0 ]; do
		echo -n "-"
		argSize=$((argSize-1))
	done
	echo
}

function printSubMenu() {
	firstColumnCount=35
	argSize=${#1}
	spaces=$((firstColumnCount-$argSize-2))

	echo -n "  $1"
	while [ $spaces -gt 0 ]; do
		echo -n ' '
		spaces=$((spaces-1))
	done
	echo "$2"
}

function deployer_info() {
	info "
To get started, use the 'deployer init' command to create a 'deployer.config' file for the current directory you are in. 
Run the 'deployer use' command to use the newly created 'deployer.config' file.

To configure the 'deployer.config' file of your current project run 'deployer config edit'. Once configured
you can run:

- deployer remote init (this will make a clone of the repository configured in the config file on the remote machine)

To view this information again run 'deployer help'"
}
