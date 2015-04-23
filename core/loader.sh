#!/usr/bin/env bash

function getDeployerLocation() {
	fileLocation=$(ls -la /usr/bin | grep 'deployer ->' | awk '{split($0, location,/ -> /); print location[2]}')
	export DEPLOYER_LOCATION=$(dirname ${fileLocation})
}

getDeployerLocation
source $DEPLOYER_LOCATION/vars/core.sh
source $DEPLOYER_LOCATION/utilities.sh

function loadDeployerConfigs() {
	# load configs
	source $DEPLOYER_LOCATION/../config/$projectFile
	if [[ -z "$localProjectLocation" ]]; then
			info "Please run 'deployer help' to get started"
		return
	fi

	if [[ ! -d "$localProjectLocation" ]]; then
		error "Local project path '$localProjectLocation' not found! Make sure the path exists..."
		return
	fi

	if [[ ! -f "$localProjectLocation/$deployerFile" ]]; then
		warning "Could not find $deployerFile file for the current project specified."
		return
	fi

	source $localProjectLocation/$deployerFile
}

function setDefaults() {
	if [[ -z $repo ]]; then
		repo=$(cd $localProjectLocation && git config --get remote.origin.url)
	fi
}

loadDeployerConfigs

# load libs
if [[ -z $localProjectLocation ]]; then
	warning "Project Location ------> Please set project location to use deployer"
else
	info "Project Location ------> $localProjectLocation"
fi

case $OSTYPE in
	"linux"* )
        source $DEPLOYER_LOCATION/normaliser.sh;;
esac

# load libs
source $DEPLOYER_LOCATION/ssher.sh
source $DEPLOYER_LOCATION/addons.sh
source $DEPLOYER_LOCATION/deploy.sh
source $DEPLOYER_LOCATION/services.sh
source $DEPLOYER_LOCATION/configParser.sh
source $DEPLOYER_LOCATION/local.sh
source $DEPLOYER_LOCATION/mysql.sh
source $DEPLOYER_LOCATION/doctor.sh
source $DEPLOYER_LOCATION/logs.sh
source $DEPLOYER_LOCATION/uninstall.sh
source $DEPLOYER_LOCATION/issues.sh
source $DEPLOYER_LOCATION/docs.sh
source $DEPLOYER_LOCATION/menu.sh
# set defaults to variables if no value is supplied prior to loading the requestHandler, the variables may be re-sourced prior to this point 
setDefaults
source $DEPLOYER_LOCATION/requestHandler.sh
