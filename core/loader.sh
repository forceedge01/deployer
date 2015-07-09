#!/usr/bin/env bash

deployerAlias=dep

function getDeployerLocation() {
	fileLocation=$(ls -la /usr/bin | grep "$deployerAlias ->" | awk '{split($0, location,/ -> /); print location[2]}')
	export DEPLOYER_LOCATION=$(dirname ${fileLocation})
}

getDeployerLocation
source $DEPLOYER_LOCATION/vars/core.sh
source $DEPLOYER_LOCATION/helpers/utilities.sh

function loadDeployerConfigs() {
	# load configs
	source $DEPLOYER_LOCATION/../config/$projectFile
	if [[ -z "$localProjectLocation" ]]; then
			info "Please run '$deployerAlias help' to get started"
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

	source "$localProjectLocation/$deployerFile"
}

function setDefaults() {
	if [[ -z $repo ]]; then
		repo=$(cd "$localProjectLocation" && git config --get remote.$remote.url)
	fi
}

loadDeployerConfigs

case $OSTYPE in
	"linux"* )
        source $DEPLOYER_LOCATION/helpers/normaliser.sh;;
esac

# load libs
source $DEPLOYER_LOCATION/local/init.sh
source $DEPLOYER_LOCATION/local/deployer.sh
source $DEPLOYER_LOCATION/local/uninstall.sh

source $DEPLOYER_LOCATION/remote/ssher.sh
source $DEPLOYER_LOCATION/remote/deploy.sh
source $DEPLOYER_LOCATION/remote/configParser.sh
source $DEPLOYER_LOCATION/remote/logs.sh
source $DEPLOYER_LOCATION/remote/remote_config.sh

source $DEPLOYER_LOCATION/menu.sh

source $DEPLOYER_LOCATION/requestHandler.sh
