#!/usr/bin/env bash

source $localProjectLocation/deployer.config &> /dev/null

function deployer_services_start() {
	attempt "start services"
	for service in "${services[@]}" 
	do
		perform "Starting service '$service'"
		deployer_ssher "sudo service $service start"
		performed
	done
}

function deployer_services_status() {
	attempt "check services"
	for service in "${services[@]}" 
	do
		perform "Check service '$service'"
		deployer_ssher "sudo service $service status"
		performed
	done
}

function deployer_services_restart() {
	attempt "restart services"
	for service in "${services[@]}" 
	do
		perform "Check service '$service'"
		deployer_ssher "sudo service $service restart"
		performed
	done	
}