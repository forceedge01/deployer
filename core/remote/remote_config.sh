#!/usr/bin/env bash

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

function deployer_remote_status() {
    deployer_run_command 'Ram Status' 'echo;free -m' 1
	echo
	for service in "${services[@]}" 
	do
        deployer_run_command "$service status" "sudo service $service status" 'Unable to reach service'
		echo
	done
	depolyer_remote_project_status
}