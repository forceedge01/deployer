#!/usr/bin/env bash
#!/usr/bin/env bash

# example command deployer push, deployer push latest, deployer push v or hash, deployer remote update, deployer update, deployer init
function helperMenu() {
	deployMenu
}

function deployMenu() {
	warning 'Deployer menu'
	printMenu 'init [path/gitrepo [path]]' "Create $deployerFile file for current directory"
	printMenu 'use' "Use the current directories $deployerFile file for deployer"
	printMenu "ssh [arg]" "log into ssh machine or run command on remote machine"
	printSubMenu 'setup' 'Setup ssh key on remote server'
	printSubMenu 'revoke' 'Revoke ssh access from remote server'

	printMenu "sshp [arg]" "ssh commands over to ssh server on the project directory"

	printMenu "deploy | d" "Deploy latest master branch on remote server"
	printSubMenu "[branch/commit/tag]" "deploy a branch, version or commit to the remote server"

	printMenu "config" "View the config file for deployer"
	printSubMenu "edit" "edit the config file for deployer"
	printSubMenu "verify" "verify the config file"

	printMenu 'project|p [arg]' 'Show project location or run command on project location'
	printSubMenu 'init' 'Initiate new project'
	printSubMenu 'list | l [path]' 'Show contents of the project directory, optional path within dir'
	printSubMenu 'open | o | web | w' 'Open project link in browser'
	printSubMenu 'repo' 'Open the repo url'
	printSubMenu 'edit | e' 'Edit current project in configured editor'
	printSubMenu 'update | u' 'Update current project locally'
	printSubMenu 'status | st' 'show status of the project'
	printSubMenu 'diff | d' 'show diff'
	printSubMenu 'checkout | ch' 'show/create/switch branches'
	printSubMenu 'merge | mr' 'merge a branch into the current branch'
	printSubMenu 'save | s' 'Save local project changes'
	printSubMenu 'dev' 'Run devStart command configured in config file'
	printSubMenu 'test' 'Run test command set in config file'
	printSubMenu 'destroy' 'Destroy project locally and removing it from the deployer project index'

	printMenu 'remote | r' 'Show remote project version'
	printSubMenu 'init | clone' 'Initialize repository on ssh server'
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

	printMenu 'issue | issues | i'
	printSubMenu 'init'
	printSubMenu 'list'
	printSubMenu 'new [title] [description] [group]'
	printSubMenu 'edit'

	printMenu 'docs | d'
	printSubMenu 'open'
	printSubMenu 'get'

	printMenu 'logs' 'Tail remote log file'
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
	gray "
To get started, use the '$deployerAlias init' command to create a '$deployerFile' file for the current directory you are in. 
Run the '$deployerAlias use' command to use the newly created '$deployerFile' file.

To configure the '$deployerFile' file of your current project run '$deployerAlias config:edit'. Once configured
you can run:

- $deployerAlias remote:init (this will make a clone of the repository configured in the config file on the remote machine)
- $deployerAlias project:edit to start editing the project selected

To view this information again run '$deployerAlias help'
"
}
