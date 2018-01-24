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
	printMenu 'manage' "Just manage the project, do not connect to remote repository."
	printMenu 'projects | ps | list [arg:int]' 'Select project no from the list of projects'
	printMenu "log" "Shows the local log of changes"
	printMenu "log-cleanup" "Empty the local log"
	printMenu "sshp [arg]" "ssh commands over to ssh server on the project directory"

	printMenu "ssh" "SSH the server"
	printSubMenu "setup" "Setup ssh keys on the remote server"
	printSubMenu "revoke" "Revoke ssh access to the remote server"

	printMenu 'project|p [arg]' 'Show project location or run command on project location'
	printSubMenu 'init' 'Initiate new project'
	printSubMenu 'select | sel' 'Select a project from the list of projects managed by deployer'
	printSubMenu 'list | l [path]' 'Show contents of the project directory, optional path within dir'
	printSubMenu 'open | o | web | w' 'Open project link in browser'
	printSubMenu 'web | w' 'Open the web URL'
	printSubMenu 'repo' 'Open the repo url'
	printSubMenu 'edit | e' 'Edit current project in configured editor'
	printSubMenu 'update | u' 'Update current project locally'
	printSubMenu 'status | st' 'show status of the project'
	printSubMenu 'diff | d' 'show diff'
	printSubMenu 'search' 'Search for a branch within the project'
	printSubMenu 'checkout | ch' 'show/create/switch branches'
	printSubMenu 'merge | mr' 'merge a branch into the current branch'
	printSubMenu 'save | s' 'Save local project changes'
	printSubMenu 'dev' 'Run devStart command configured in config file'
	printSubMenu 'test' 'Run test command set in config file'
	printSubMenu 'remove' 'Remove project from deployer logs'
	printSubMenu 'destroy' 'Destroy project locally and removing it from the deployer project index'

	printMenu 'remote | r' 'Show remote project version'
	printSubMenu 'init | clone' 'Initialize repository on ssh server'
	printSubMenu "reclone" "Re-Initialize repository on ssh server"
	printSubMenu 'deploy | d [arg:string]?' 'Deploy branch/tag specified, latest tag if latest given as arg.'
	printSubMenu 'checkout | ch' 'Checkout remote branch'
	printSubMenu 'search' 'Search for branch on remote server'
	printSubMenu "update" "update remote server"
	printSubMenu "tags" "view tags available on remote machine"
	printSubMenu "status" "show status of remote machine"
	printSubMenu "logs" "show remote logs on the server"
	printSubMenu "upload [arg]" "upload file/folder to ssh server's configured uploads directory"
	printSubMenu "download [arg]" "download file/folder to ssh server's configured downloads directory"
	printSubMenu 'keys' 'View SSH authorized_keys file on remote server'
	printSubMenu 'dependencies | deps' 'Check remote dependencies defined in config'
	printSubMenu 'get [file/folderPath]' 'Get a file/folder from the remote server'
	printSubMenu 'services status' 'status of all configured services on remote machine'
	printSubMenu 'services start' 'start services configured on remote machine'
	printSubMenu 'services restart' 'restart services configured on remote machine'
	printSubMenu 'service status [service]' 'status single custom service'
	printSubMenu 'service start [service]' 'start single custom service'
	printSubMenu 'service stop [service]' 'stop single custom service'
	printSubMenu 'service restart [service]' 'restart single custom service'

	printMenu "config | c" "View the config file for deployer"
	printSubMenu "edit | e" "edit the config file for deployer"
	printSubMenu "verify | doctor | v" "verify the config file"

	printMenu 'downloads'
	printSubMenu 'open [arg:string]' 'Open a downloaded file'
	printSubMenu 'get [arg:string]' 'Download a file from the remote download folder'
	printSubMenu 'list' 'List downloaded files on local'

	printMenu 'issue | issues | i'
	printSubMenu 'init'
	printSubMenu 'list'
	printSubMenu 'new [title] [description] [group]'
	printSubMenu 'edit'

	printMenu "update | u" "Update deployer"
	printMenu "uninstall" "uninstall deployer"
	printMenu "--version | -v " "Display deployer version"

	printMenu 'dev'
	printSubMenu 'edit' 'Edit deployer source'
	printSubMenu 'save' 'Save changes made to deployer source'

	printMenu '--help' 'Shows how to use deployer'
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
