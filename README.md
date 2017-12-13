# deployer
A simple script that will handle project deployment on a remote ssh server. The objective being making the script language independent and as simple as possible.

## Supported OS
Local machine:
- OSX
- Ubuntu
- Windows (Hack) - Refer to section 'Windows Hack'.

Remote server:
- Centos 6 (tested)

Deployer should work on any cli that has bash available.

## Installation
To get started run 

```
git clone https://github.com/forceedge/deployer.git; chmod 0777 deployer/init.sh; cd deployer; ./init.sh
```
**Note: You can change the alias to be whatever you want in the init file, just set the deployerAlias to what you would like and run the command above.**

## Setup/Initialise project with deployer
To get a project deployed with deployer use the following command in the project directory

```
deployer init
```

This will create the deploy.conf file in your project, to use/edit this file with deployer run

```
deployer use
```

This will show  a message confirming that the file is being used with deployer. You can quickly edit this file by running
```
deployer config:edit
```

Deploying is as easy as
```
deployer deploy
```

Or a specific branch
```
deployer deploy mybranch
```

To quickly setup ssh keys on the remote server, just run:

```
deployer ssh:setup
```

## Menu/Commands
on the command line type 
```
deployer
```
to view the menu.

### Config file
```bash
#!/usr/bin/env bash

# This is the config file that runs with deployer. Any variable marked with a 
# '*' comment means its crucial to deployer working properly, use 'deployer 
# config:verify' to check your configuration once you are done setting variables.

# server settings
# server ip to connect to
declare sshServer='' # *
# connect to SSH server as
declare username='' # *

# ---------------------------------------------–------- #

# SSH debug settings
# set the verbositiy of the deployment process
declare verbose=0

# ---------------------------------------------–------- #

# deploy settings
# services to check for after deployment
declare services=(httpd mysqld)
# set maintenance page content here, will be used to create an index.html page when deploying and fill it 
# with the content you have set below, if left empty the index.html page will not be created at all
# any content set previously will be erased if content is set
declare maintenancePageContent=''
# command to run before deployment starts, by default runs in the project directory
declare preDeployCommand=''
# command to run after deployment is done, by default runs in the project directory
declare postDeployCommand=''
# do not ask for confirmation before deployment
declare permissiveDeployment=false
# set downloads folder for deployer
declare downloadsPath='~/deployer_downloads'
# set uploads folder for deployer
declare uploadsPath='~/deployer_uploads'

# ---------------------------------------------–------- #

# mysql server settings
# the user to connect as to mysql
declare dbUser=''
# should a password be used, usefull if you dont set a password in this file and still want mysql to prompt for password
declare usePassword='true'
# set the password for mysql db, strictly speaking this isnt recommended as there are chances of exposing your password
declare dbPassword=''
# the database name, optional
declare dbName=''

# ----------------------------------------------------- #
# app specific settings
declare editor='vim'
# allow push to master branch
declare allowSaveToMaster=false
# project location on SSH server
# Show diff before saving
declare showDiffBeforeSave=true
declare remoteProjectLocation=''
# project repo url, if not set default origin url will be used
declare repo=''
# project web url, is used with open command
declare webURL=''
# change config file params, relative to the remote project location or absolute, 
# space separated list
declare configFiles=()
# changes to make in config file specified, i.e ("string" "replace") 
# i.e ("DEFINE('ROOT', __DIR__);" "DEFINE('ROOT', 'my/path');")
# escaped characters list ', ", (, ), < >, /, <,>, ;
# Note that . and * are not escaped and are valid regex expressions
# Above example can be re-written as ("DEFINE('ROOT', .*" "DEFINE('ROOT', 'my/path');")
declare config=(
 "" ""
)
# log filepath for this app
declare logFiles=()
# any command to run on the local project using the deployer project:dev command, separate commands by ';' delimiter
declare devStart=''
# an alias to the command you want to set to have the tests run
declare testStart=''

# ---------------------------------------------–------- #
```

## Useful Aliases
As part of deployer, you get the following aliases:
- relaod
Reload will reload the ~/.bashrc file for you.

- project
The project alias can be used to switch immediate to the the current project directory being used by deployer. 

## Dependencies
The local machine and remote server must have git installed.

## Windows Hack
To get this tool working on windows you will need to hack the loader.sh file, line 7. Just set the
deployer path as a string and everything else should just work.

Recommended configuration for windows is install a bash tool such as git bash for windows.
Download deployer and follow the usual install instructions.