#!/usr/bin/env bash

function Deployer_tail_logs() {
    if [[ -z $logFiles ]]; then
        error 'You need to set the logFiles variable in the config file in order to tail it'
        return
    fi

    logCommand=''
	perform 'Tail log files'
    for logFile in "${logFiles[@]}"
	do
        logCommand=$logCommand" -f $logFile "
    done
    
    deployer_ssher "tail $logCommand"
}
