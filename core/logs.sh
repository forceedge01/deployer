#!/usr/bin/env bash

function Deployer_tail_logs() {
	deployer_run_command 'Tail log file' "tail -f $appLog" 'Unable to tail log file, make sure it exists'
}