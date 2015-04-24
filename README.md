# deployer
A simple script that will handle project deployment on a remote ssh server. The objective being making the script language independent and as simple as possible.

## Supported OS
Local machine:
- OSX (tested)
- Ubuntu (tested)

Remote server:
- Centos 6 (tested)

Deployer should work on any cli that has bash tools available.

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
```
#!/usr/bin/env bash

# server settings
# server ip to connect to
declare sshServer=''
# connect to SSH server as
declare username=''

# ---------------------------------------------–------- #

# SSH debug settings
# set the verbositiy of the deployment process
declare verbose=0

# ---------------------------------------------–------- #

# deploy settings
# services to check for after deployment
declare services=(httpd mysqld)
# deploy using git or scp
declare deploymentMethod='git'
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
# should a password be used, usefull if you dont set a password in the config and still want mysql to prompt for password
declare usePassword='true'
# set the password for mysql db, strictly speaking this isnt recommended as there are chances of exposing your password
declare dbPassword=''
# the database name, optional
declare dbName=''

# ----------------------------------------------------- #
# app specific settings
declare editor='vim'
# project location on SSH server
declare remoteProjectLocation=''
# project repo url
declare repo=''
# project web url, is used with open command
declare webURL=''
# change config file params, relative to the remote project location or absolute
declare configFiles=()
# changes to make in config file specified, i.e ('regex' 'value')
declare config=()
# log filepath for this app
declare appLog=''
# any command to run on the local project using the deployer dev command
declare devStart=''

# ---------------------------------------------–------- #
```

## Dependencies
The local machine and remote server must have git installed.
