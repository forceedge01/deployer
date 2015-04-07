#!/usr/bin/env bash

source $localProjectLocation/$deployerFile &> /dev/null

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

function deployer_remote_download() {
	if [[ -z $downloadsPath ]]; then
		error 'downloadsPath must be set in config file'
		return 1
	fi

	if [[ -z "$1" ]]; then
		attempt "list downloads directory: '$downloadsPath'"
		deployer_ssher_toDir "ls -la $downloadsPath | sed 2,3d"
		return 0
	fi
	attempt "download file from '$1'"
	perform 'Check if the download url is valid'
	header=$(curl -sI $1)
	length=$(echo "$header" | grep 'Content-Length' | awk '{split($0,chunks," "); print chunks[2]}' | xargs)
	status=$(echo "$header" | grep 'HTTP/1.1' | awk '{split($0,chunks," "); print chunks[2]}' | xargs)
	if [[ $length < 1 ]] || [[ $status =~ ^4|5\d{2}$ ]]; then
		error 'The download link is invalid'
		return
	fi
	performed
	deployer_run_command "Make sure '$downloadsPath' exists" "mkdir -p $downloadsPath" 'Unable to create folder path'
	perform 'Download and show file'
	echo
	deployer_ssher_toDir "cd $downloadsPath && curl -#OL '$1'; ls -la | sed 2,3d"
}

function deployer_local_upload() {
	if [[ -z $uploadsPath ]]; then
		error 'uploadsPath must be set in config file'
		return 1
	fi

	if [[ -z "$1" ]]; then
		attempt "list uploads directory: '$uploadsPath'"
		deployer_ssher "ls -la $uploadsPath | sed 2,3d"
		return
	fi
	attempt "upload file/folder to $sshServer"
	perform 'Check path provided'
	recurse=''
	if [[ -f "$1" ]]; then
		performed 'File'
	elif [[ -d "$1" ]]; then
		performed 'Folder'
		recurse='-r'
	else
		error 'The path specified is not a file or folder'
		return 234
	fi
	deployer_ssher_toDir 'Make sure the uploads dir exists' "mkdir -p $uploadsPath" 'Unable to create uploads path!'
	perform 'SCP file/folder to server'
	scp $recurse "$1" "$username@$sshServer:$uploadsPath"
	performed
	perform 'Show uploads folder contents'
	deployer_ssher "ls -la $uploadsPath | sed 2,3d"
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
