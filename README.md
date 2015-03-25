# deployer
A simple script that will handle project deployment on a remote ssh server. The objective being making the script language independent and as simple as possible.

## Installation
To get started run 

```
git clone https://github.com/forceedge/deployer.git; chmod 0777 deployer/init.sh; cd deployer; ./init.sh
```
## Setup/Initialise project with eployer
To get a project deployed with deployer use the following command in the project directory

```
deployer init
```

This will create the deployer.config file in your project, to use/edit this file with deployer run

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

## Menu/Commands
on the command line type 
```
deployer
```
to view the menu.

### Config file
```
# server settings
# server ip to connect to
declare sshServer=''
# connect to SSH server as
declare username=''

# ---------------------------------------------–------- #

# SSH settings
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

# app specific settings
declare editor='vim'
# project location on SSH server
declare remoteProjectLocation=''
# project repo url
declare repo=''
# project web url, is used with open command
declare webURL=''
# change config file params
declare configFiles=('')
# changes to make in config file specified, i.e ('regex' 'value')
declare config=()

# ---------------------------------------------–------- #
```

## Dependencies
The local machine and remote server must have git installed.
