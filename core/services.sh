#!/usr/bin/env bash

source $localProjectLocation/deployer.config &> /dev/null

function deployer_services_start() {
	deployer_private_runServicesWith 'starting' 'start'
}

function deployer_services_status() {
	deployer_private_runServicesWith 'check' 'status'
}

function deployer_services_restart() {
	
	deployer_private_runServicesWith 'restart' 'restart'
}

function deployer_private_runServicesWith() {
	attempt "$1 services"
	for service in "${services[@]}" 
	do
		perform "$1 service '$service'"
		deployer_ssher "sudo service $service $2"
		performed
	done
}