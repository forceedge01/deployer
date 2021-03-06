#!/usr/bin/env bash

# define cases in this file and run them
IFS=':' read -ra ADDR <<< "$1"
service="${ADDR[0]}"
action="${ADDR[1]}"

# load custom file for environment, provided by the -e flag.
# This file will override variables set in the usual deployer.conf file
for opt in "$@"; do
	case $opt in
		'env'*)
			# Extract value from opt variable
			IFS='=' read -ra ADDR <<< "$opt"
			env=${ADDR[1]}

			# Concatinate new file name
			confFile="$env"_"$deployerFile"

			# Check if the file exists
			info "Attempting to include custom conf file: $confFile"
			if [[ ! -f "$localProjectLocation/$confFile" ]]; then
				error "Custom conf file '$confFile' not found!"
				exit
			fi

			# Load new file
			source "$localProjectLocation/$confFile";
			2=
	esac
done

# Forward action request to proper handler
case "$service" in
	'use' )
		deployer_use;;
	'init' )
		deployer_init;;
	'manage' )
		deployer_manage;;
	'clone' )
		deployer_clone "$2";;
	'log' )
		Deployer_commit_log "$2";;
	'log-cleanup' )
		echo '' > $DEPLOYER_LOCATION/../logs/project-commits.log;;
	'ssh' )
		case "$action" in
			'setup' )
				deployer_ssh_setup;;
			'revoke' )
				Deployer_ssh_revoke;;
			* )
				deployer_ssher "${@:2}";;
		esac;;
	'sshp' )
		deployer_ssher_toDir "${@:2}";;
	'project' | 'p' )
		# load relative files
		source $DEPLOYER_LOCATION/local/project.sh
		# handle cases
		case "$action" in 
			'init' )
				Deployer_project_init "$2" "$3";;
			'list' | 'l' )
				Deployer_project_list "$2";;
			'web' | 'w' )
				deployer_open_web;;
			'open' | 'o' )
				deployer_open_dir;;
			'repo' )
				open $(Deployer_repo_url);;
			'edit' | 'e' )
				deployer_local_edit_project;;
			'update' | 'u' )
				Deployer_project_update;;
			'save' | 's' )
				Deployer_project_save "$2";;
			'diff' | 'd' )
				Deployer_project_diff "$2";;
			'status' | 'st' )
				Deployer_project_status;;
			'checkout' | 'ch' )
				Deployer_project_checkout "$2";;
			'search' )
				Deployer_project_search "${@:2}";;
			'merge' | 'mr' )
				Deployer_project_merge "$2";;
			'select' | 'sel' )
				deployer_select_project "$2";;
			'test' | 't' )
				Deployer_project_test;;
			'dev' )
				deployer_dev;;
			'destroy' )
				Deployer_project_destroy;;
			'remove' | 'unmanage' )
				Deployer_project_remove;;
			* )
				Deployer_local_run "${@:2}";;
		esac;;
	'projects' | 'ps' | 'list' )
		# load relative files
		source $DEPLOYER_LOCATION/local/project.sh
		deployer_select_project "$2";;
	'addons' )
		# load files
		source $DEPLOYER_LOCATION/local/addons.sh

		# handle cases
		case "$action" in 
			'get' )
				Deployer_addons_get "$2";;
			'remove' )
				Deployer_addons_remove "$2";;
			* )
				Deployer_addons_list;;
		esac;;
	'downloads' | 'dl' )
		# load files
		source $DEPLOYER_LOCATION/local/downloads.sh

		# handle cases
		case "$action" in 
			'open' )
				Deployer_downloads_open "$2";;
			'get' )
				Deployer_downloads_get "$2";;
			* )
				Deployer_downloads_list;;
		esac;;
	'remote' | 'r' | 'staging' )
		case "$action" in
			'init' | "clone" )
				deployer_remote_init;;
			'deploy' | 'd' )
				case "$2" in 
					'latest' )
						deployer_deploy_latest;;
					* )
						deployer_deploy "$2";;
				esac;;
			'ch' | 'checkout' )
				deployer_remote_checkout "$2";;
			'search' )
				deployer_remote_search "${@:2}";;
			'reclone' )
				deployer_reclone;;
			'logs' )
				Deployer_tail_logs;;
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
			'keys' )
				deployer_remote_keys;;
			'dependencies' | 'deps' )
				deployer_check_depenedencies_remote;;
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
			'verify' | 'doctor' | 'v' )
				deloyer_config_doctor;;
			* )
				echo 'Displaying project file...'; 
				cat "$localProjectLocation/$deployerFile";
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
				Deployer_issue_new "$2" "$3" "$4";;
			'edit' )
				Deployer_issue_edit;;
			* )
				Deployer_issue_list "$2";;
		esac;;
	'dev' )
		case "$action" in 
			'save' )
				Deployer_save;;
			'edit' )
				Deployer_edit;;
			'diff' )
				Deployer_diff;;
		esac;;
	'update' | 'u' )
		Deployer_update;;
	'uninstall' )
		deployer_uninstall;;
	'--version' | '-v' )
		Deployer_version;;
	'--help' )
		deployer_info;;
	*)
		helperMenu;;
esac
# inject linespace
echo 
