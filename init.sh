#!/usr/bin/env bash
# add code to bashrc file so deploy can be used

# check if alias exists, if not add it.

if [[ ! -f $(pwd)/init.sh ]]; then
	echo 'This script needs to run from the project folder, aborting...'
else
	currentDirectory=$(pwd)
	echo 'Sorting out file permissions...'
	chmod -R 0777 ./core
	echo 'Checking for alias in bashrc file...'

	if [[ $(alias|grep deploy) == '' ]]; then
		echo 'Adding alias to bashrc file...'
		echo "source $currentDirectory/core/deploy.sh" >> ~/.bashrc
	else
		echo 'Alias already exists...'
	fi

	echo 'Use the "deploy", "init" aliases to deploy your project to the ssh server"'

fi

echo 'Done.'