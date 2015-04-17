#!/usr/local/env bash

function deployer_mysql() {
	mysqlCommand=$(deployer_get_connection_string)
	perform 'Log into MySQL'
	deployer_ssher "$mysqlCommand"
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
