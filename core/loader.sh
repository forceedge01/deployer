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
	if [[ -z "$localProjectLocation" ]]; then
			info "Please run 'deployer help' to get started"
		return
	fi

	if [[ ! -d "$localProjectLocation" ]]; then
		error "Local project path '$localProjectLocation' not found! Make sure the path exists..."
		return
	fi

	if [[ ! -f "$localProjectLocation/deployer.config" ]]; then
		warning 'Could not find deployer.config file for the current project specified.'
		return
	fi

	source $localProjectLocation/deployer.config
	# use this to replace string.
	#sed -i ".bk" 's/alias project/alias SOMETHING=\/Volumes\/Projects/' foo
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
source $DEPLOYER_LOCATION/deploy.sh
source $DEPLOYER_LOCATION/services.sh
source $DEPLOYER_LOCATION/configParser.sh
source $DEPLOYER_LOCATION/local.sh
source $DEPLOYER_LOCATION/doctor.sh
source $DEPLOYER_LOCATION/logs.sh
source $DEPLOYER_LOCATION/uninstall.sh
source $DEPLOYER_LOCATION/menu.sh
source $DEPLOYER_LOCATION/requestHandler.sh
