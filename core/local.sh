#!/usr/bin/env bash

function deployer_local_update() {
	cd $localProjectLocation && git pull origin
}