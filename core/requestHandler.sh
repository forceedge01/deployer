#!/usr/bin/env bash

# define cases in this file and run them
case "$1" in 
	'use' )
		deployer_use;;
	'init' )
		deployer_init;;
	'ssh' )
		case "$2" in
			'setup' )
				deployer_ssh_setup;;
			* )
				deployer_ssher "$2";;
		esac;;
	'sshp' )
		deployer_ssher_toDir "$2";;
	'deploy' | 'd' )
		case "$2" in 
			'latest' )
				deployer_deploy_latest;;
			* )
				deployer_deploy "$2";;
		esac;;
	'get' )
		deployer_remote_get "$2";;
	'remote' | 'r' )
		case "$2" in
			'init' | "clone" )
				deployer_remote_init;;
			'reclone' )
				deployer_reclone;;
			'update' )
				deployer_remote_update;;
			'tags' )
				deployer_remote_tags;;
			'status' )
				deployer_remote_status;;
			'download' | 'downloads')
				deployer_remote_download "$3";;
			'upload' | 'uploads' )
				deployer_local_upload "$3";;
			'services' )
				case "$3" in 
					'start' )
						deployer_services_start;;
					* )
						deployer_services_status;;
				esac;;
			'service' )
				case "$3" in
					'start' )
						deployer_service_perform 'start' "$4";;
					'stop' )
						deployer_service_perform 'stop' "$4";;
					'restart' )
						deployer_service_perform 'restart' "$4";;
					'status' )
						deployer_service_perform 'stop' "$4";;
				esac;;
			* )
				depolyer_remote_project_status;;
		esac;;
	'config' | 'c' )
		case "$2" in 
			'edit' | 'e' )
				$editor $localProjectLocation/deployer.config;;
			'verify' | 'v' )
				deployer_config_status;;
			* )
				echo 'Displaying project file...'; 
				cat $localProjectLocation/deployer.config;
				echo '';;
		esac;;
	'update' | 'u' )
		deployer_local_update;;
	'self-update' )
		cd $DEPLOYER_LOCATION && git pull origin && git pull origin --tags;;
	'open' | 'web' )
		deployer_open_web;;
	'uninstall' )
		deployer_uninstall;;
	'version' | 'v' )
		Deployer_version;;
	'edit' | 'e' )
		deployer_local_edit_project;;
	'project' | 'p' )
		;;
	'help' )
		deployer_info;;
	*)
		helperMenu;;
esac
# inject linespace
echo 
