#!/usr/bin/env bash

# define cases in this file and run them
IFS=':' read -ra ADDR <<< "$1"
service="${ADDR[0]}"
action="${ADDR[1]}"

case "$service" in 
	'use' )
		deployer_use;;
	'init' )
		deployer_init;;
	'logs' )
		Deployer_tail_logs;;
	'dev' )
		deployer_dev;;
	'ssh' )
		case "$action" in
			'setup' )
				deployer_ssh_setup;;
			* )
				deployer_ssher "$2";;
		esac;;
	'sshp' )
		deployer_ssher_toDir "$2";;
	'project' | 'p' )
		# load relative files
		source $DEPLOYER_LOCATION/local/project.sh
		# handle cases
		case "$action" in 
			'open' | 'web' | 'w' | 'o' )
				deployer_open_web;;
			'repo' )
				open $(Deployer_repo_url);;
			'edit' | 'e' )
				deployer_local_edit_project;;
			'update' | 'u' )
				deployer_local_update;;
			'save' | 's' )
				Deployer_project_save;;
			'diff' | 'd' )
				Deployer_project_diff "$2";;
			'status' | 'st' )
				Deployer_project_status;;
			'checkout' | 'ch' )
				Deployer_project_checkout "$2";;
			'select' )
				deployer_select_project "$2";;
			* )
				Deployer_local_run "$2";;
		esac;;
	'deploy' | 'd' )
		case "$2" in 
			'latest' )
				deployer_deploy_latest;;
			* )
				deployer_deploy "$2";;
		esac;;
	'addons' )
		# load files
		source $DEPLOYER_LOCATION/local/addons.sh

		# handle casees
		case "$action" in 
			'get' )
				Deployer_addons_get "$2";;
			'remove' )
				Deployer_addons_remove "$2";;
			* )
				Deployer_addons_list;;
		esac;;
	'docs' | 'd' )
		# load files
		source $DEPLOYER_LOCATION/local/docs.sh

		# handle cases
		case "$action" in 
			'open' )
				Deployer_docs_open "$2";;
			'get' )
				Deployer_docs_get "$2";;
			* )
				Deployer_docs_list;;
		esac;;
	'remote' | 'r' )
		case "$action" in
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
				source $DEPLOYER_LOCATION/remote/download_upload.sh

				deployer_remote_download "$2";;
			'upload' | 'uploads' )
				source $DEPLOYER_LOCATION/remote/download_upload.sh
				
				deployer_local_upload "$2";;
			'get' )
				deployer_remote_get "$2";;
			'services' )
				# load relative files
				source $DEPLOYER_LOCATION/remote/services.sh
				
				# handle cases
				case "$2" in 
					'start' )
						deployer_services_start;;
                    'restart')
                        deployer_services_restart;;
					* )
						deployer_services_status;;
				esac;;
			'service' )
				# load relative files
				source $DEPLOYER_LOCATION/remote/services.sh

				# handle cases
				case "$2" in
					'start' )
						deployer_service_perform 'start' "$3";;
					'stop' )
						deployer_service_perform 'stop' "$3";;
					'restart' )
						deployer_service_perform 'restart' "$3";;
					'status' )
						deployer_service_perform 'status' "$3";;
				esac;;
            'mysql' | 'ms')
				# load files
				source $DEPLOYER_LOCATION/../addons/mysql.sh

                deployer_mysql;;
            * )
				depolyer_remote_project_status;;
		esac;;
	'config' | 'c' )
		# load relative files
		source $DEPLOYER_LOCATION/local/config.sh

		# handle cases
		case "$action" in 
			'edit' | 'e' )
				Deployer_config_edit;;
			'verify' | 'v' )
				deloyer_config_doctor;;
			* )
				echo 'Displaying project file...'; 
				cat $localProjectLocation/$deployerFile;
				echo '';;
		esac;;
	'issue' | 'issues' | 'i' )
		# load relative files
		source $DEPLOYER_LOCATION/local/issues.sh

		# handle cases
		case "$action" in
			'init' )
				Deployer_issue_init;;
			'list' )
				Deployer_issue_list;;
			'new' )
				Deployer_issue_new "$2" "$3";;
			'edit' )
				Deployer_issue_edit;;
			* )
				Deployer_issue_list;;
		esac;;
	'update' | 'u' )
		Deployer_update;;
	'uninstall' )
		deployer_uninstall;;
	'version' | 'v' )
		Deployer_version;;
	'help' | '--help' )
		deployer_info;;
	*)
		helperMenu;;
esac
# inject linespace
echo 
