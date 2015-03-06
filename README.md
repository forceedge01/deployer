# deployer
A simple script that will handle project deployment on a remote ssh server. The objective being making the script language independent and as simple as possible.

## Installation
To get started run 

```
git clone https://github.com/forceedge/deployer.git; chmod 0777 deployer/init.sh; cd deployer; ./init.sh
```
After the script has completed, it will ask you to set the config file.

## Menu/Commands
on the command line type 
```
deployer
```
to view the menu.

### Config file
```
# server settings
# the ssh server ip
readonly sshServer=''
# username to ssh with
readonly username=''

# app specific settings
# location of the project on local machine
readonly localProjectLocation=''
# location of the project on the remote machine
readonly remoteProjectLocation=''
# repository, https recommended
readonly repo=''
# url for the project
readonly web=''

# ssh settings
# set message output when sshing
readonly verbose=0
```

## Dependencies
The local machine and remote server must have git installed.
