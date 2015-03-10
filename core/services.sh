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

function deployer_service_perform() {
	if [[ -z "$2" ]]; then
		error 'Service name must be passed in as argument'
		return
	fi

	attempt "$1 service '$2'"
	perform "send command to $1 service"
	deployer_ssher "sudo service $2 $1"
	performed
}

function deployer_private_runServicesWith() {
	attempt "$1 services"
	for service in "${services[@]}" 
	do
		deployer_service_perform "$1" "$2"
	done
}

function deployer_vhost_create() {
	attempt 'create a virtualhost on remote machine'
	if [[ -z "$1" ]]; then
		error 'You must provide with a virtual host name'
		return 1
	fi
	perform 'Enter host definition in httpd.conf file'
	$(deployer_ssher 'echo "<VirtualHost *:80>
    ServerAdmin $username@$1.com
    DocumentRoot $remoteProjectLocation
    ServerName $1
    ErrorLog logs/$1-error.log
</VirtualHost>" >> /etc/httpd/conf/httpd.conf')
	performed
}