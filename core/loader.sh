#!/usr/bin/env bash

function getDeployerLocation() {
	fileLocation=$(ls -la /usr/bin | grep 'deployer ->' | awk '{split($0, location,/ -> /); print location[2]}')
	export DEPLOYER_LOCATION=$(dirname ${fileLocation})
}

getDeployerLocation
source $DEPLOYER_LOCATION/utilities.sh

function loadDeployerConfigs() {
	# load configs
	source $DEPLOYER_LOCATION/../config/project.sh
	if [[ ! -f "$localProjectLocation/deployer.config" ]]; then
		warning 'could not find deployer.config file for the current project specified.'
		return
	fi

	source $localProjectLocation/deployer.config
}

loadDeployerConfigs

# load libs
source $DEPLOYER_LOCATION/ssher.sh
source $DEPLOYER_LOCATION/deploy.sh
source $DEPLOYER_LOCATION/services.sh
source $DEPLOYER_LOCATION/uninstall.sh
source $DEPLOYER_LOCATION/menu.sh
source $DEPLOYER_LOCATION/requestHandler.sh