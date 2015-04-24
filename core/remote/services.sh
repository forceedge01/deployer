#!/usr/bin/env bash

source $localProjectLocation/$deployerFile &> /dev/null
# set defaults to variables if no value is supplied prior to loading the requestHandler, the variables may be re-sourced prior to this point 
setDefaults

function deployer_services_start() {
	deployer_private_runServicesWith 'starting' 'start'
}

function deployer_services_status() {
	deployer_private_runServicesWith 'check' 'status'
}

function deployer_services_restart() {

	deployer_private_runServicesWith 'restart' 'restart'
}

function deployer_service_perform() {
	if [[ -z "$2" ]]; then
		error 'Service name must be specified'
		return
	fi

	attempt "$1 service '$2'"
	deployer_run_command "send command to $1 service" "sudo service $2 $1" 'Unable to start service!'
}

function deployer_private_runServicesWith() {
	attempt "$1 services"
	for service in "${services[@]}" 
	do
		deployer_service_perform "$2" "$service"
	done
}