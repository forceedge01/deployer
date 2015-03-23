#!/usr/local/env bash

function deployer_mysql() {
deployer_run_command 'Connect to mysql' "$(deployer_get_connection_string)" 'Unable to connect, make sure mysql is running or the ssh server is reachable'
}

function deployer_get_connection_string() {
    if [[ ! -z $dbUser ]]; then
        dbUser='-u '$dbUser
        if [[ ! -z $dbPassword ]]; then
            dbPassword='--password='$dbPassword
        elif [[ $usePassword == true ]]; then
            dbPassword='-p'
        fi
    fi
    echo "mysql $dbUser $dbPassword $dbName"
}
