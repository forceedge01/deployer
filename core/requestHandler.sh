#!/usr/bin/env bash

function getDeployerLocation() {
	fileLocation=$(ls -la /usr/bin | grep 'deployer ->' | awk '{split($0, location,/ -> /); print location[2]}')
	export DEPLOYER_LOCATION=$(dirname ${fileLocation})
}

getDeployerLocation

source $DEPLOYER_LOCATION/deploy.sh
source $DEPLOYER_LOCATION/menu.sh

# define cases in this file and run them

case $1 in 
	"init" )
		deployer_init;;
	"ssh" )
		deployer_ssher "$2";;
	"sshp" )
		deployer_ssher_toDir "$2";; 
	"deploy" )
		case $2 in 
			"latest" )
				deployer_deploy_latest;;
			* )
				deployer_deploy;;
		esac;;
	"remote" )
		case $2 in
			"update" )
				deployer_remote_update;;
			"tags" )
				deployer_remote_tags;;
		esac;;
	"config" )
		case $2 in 
			"edit" )
				vim $DEPLOYER_LOCATION/../config;;
			* )
				echo 'Displaying config file...'; cat $DEPLOYER_LOCATION/../config/main.sh; echo '';;
		esac;;
	"update" )
		cd $DEPLOYER_LOCATION; git pull origin master;;
	*)
		helperMenu;;
esac