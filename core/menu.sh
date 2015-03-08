#!/usr/bin/env bash
#!/usr/bin/env bash

# example command deployer push, deployer push latest, deployer push v or hash, deployer remote update, deployer update, deployer init
function helperMenu() {
	deployMenu
}

function deployMenu() {
	echo 'Deployer menu'
	printMenu 'init' 'Create deployer.config file for current directory'
	printMenu 'use' 'Use the current directories deployer.config file for deployer'
	printMenu "ssh" "log into ssh machine"
	printMenu "ssh [arg]" "ssh commands over to ssh server"
	printMenu "sshp [arg]" "ssh commands over to ssh server on the project directory"
	printMenu "deploy | d" "Deploy latest master branch on remote server"
	printMenu "deploy [branch/commit/tag]" "deploy a branch, version or commit to the remote server"
	printMenu 'get [file/folderPath]' 'Get a file/folder from the remote server'
	printMenu "remote" "Show remote project version"
	printMenu "remote init | clone" "Initialize repository on ssh server"
	printMenu "remote reclone" "Re-Initialize repository on ssh server"
	printMenu "remote update" "update remote server"
	printMenu "remote tags" "view tags available on remote machine"
	printMenu "remote status" "show status of remote machine"
	printMenu 'remote services status' 'status of all configured services on remote machine'
	printMenu 'remote services start' 'start services configured on remote machine'
	printMenu 'remote services restart' 'restart services configured on remote machine'
	printMenu 'remote service status [service]' 'status single custom service'
	printMenu 'remote service start [service]' 'start single custom service'
	printMenu 'remote service stop [service]' 'stop single custom service'
	printMenu 'remote service restart [service]' 'restart single custom service'
	printMenu "remote upload [arg]" "upload file/folder to ssh server's configured uploads directory"
	printMenu "remote download [arg]" "download file/folder to ssh server's configured downloads directory"
	printMenu "config" "View the config file for deployer"
	printMenu "config edit" "edit the config file for deployer"
	printMenu "update" "update deployer"
	printMenu "open | web" "Open project link in browser"
	printMenu 'edit' 'Edit current project in configured editor'
	printMenu 'update' 'Update current project locally'
	printMenu 'self-update' 'Update deployer'
	printMenu "version | v" "Display deployer version"
	printMenu "uninstall" "uninstall deployer"
}

function printMenu() {
	firstColumnCount=35
	argSize=${#1}
	spaces=$((firstColumnCount-$argSize))
	
	echo '----------------------------------------------------------------------------------------'
	echo -n "$1"
	while [ $spaces -gt 0 ]; do
		echo -n ' '
		spaces=$((spaces-1))
	done
	echo "$2"
}

function deployer_info() {
	info "
To get started, use the 'deployer init' command to create a 'deployer.config' file for the current directory you are in. 
Use the 'deployer use' command to use the 'deployer.config' file with deployer.

To configure the 'deployer.config' file of your current project run 'deployer config edit'. Once configured
you can run:

- deployer remote init (this will make a clone of the repository configured in the config file)

To view this information again run 'deployer help'"
}
