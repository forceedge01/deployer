#!/usr/bin/env bash
# add code to bashrc file so deploy can be used

# check if alias exists, if not add it.

currentDirectory=$(pwd)

if [[ ! -f $currentDirectory/init.sh ]]; then
	echo 'This script needs to run from inside the deployer folder, aborting...'
else
	echo 'Checking for deployer installation...'

	if [[ ! -f /usr/bin/deployer ]]; then
		echo 'Sorting out file permissions...'
		chmod -R 0777 ./core

		echo 'Creating symlink...'
		sudo ln -s $currentDirectory/core/loader.sh /usr/bin/deployer

		if [[ ! -f $currentDirectory/config/main.sh ]]; then
			echo 'Setup current project'
			cp $currentDirectory/config/project.sh.dist $currentDirectory/config/project.sh
		fi
	else
		echo 'Already installed...'
	fi

	echo -n 'Detecting OS: '$OSTYPE
	case $OSTYPE in
		"darwin"* )
			echo 'Supported OS'
		"linux"* )
			echo 'Supported OS, adding aliases to normalise deployer environment'
			echo "alias open='xdg-open'" >> ~/.bashrc
			echo "alias deployer='bash deployer'" >> ~/.bashrc
		* )
			echo 'Unsupported OS'
	esac

	echo 'Use the "deployer" command to get started..."'
fi

echo 'Done.'
