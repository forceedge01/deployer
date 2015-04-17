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
			source $currentDirectory/core/vars/core.sh
			echo 'Setup current project'
			cp $currentDirectory/config/$projectFileDistributable $currentDirectory/config/$projectFile
		fi
        echo 'Exporting variable $project to bashrc file'
        echo "alias project=\"cd \$(deployer p | awk '{split(\$0,chunks,\" \"); print chunks[4]}')\"" >> ~/.bashrc
	else
		echo 'Already installed...'
	fi

	echo 'Detecting OS: '$OSTYPE
	case $OSTYPE in
		"darwin"* )
			echo 'Supported OS';;
		"linux"* )
			echo 'Supported OS, adding aliases to bashrc file to normalise deployer environment'
			echo '# Deployer aliases' >> ~/.bashrc
			echo 'alias deployer="bash deployer"' >> ~/.bashrc
			echo '# End of deployer aliases and functions' >> ~/.bashrc
			echo 'Make sure the bashrc file is sourced before using the deployer command'
			source ~/.bashrc;;
		* )
			echo 'Unsupported OS';;
	esac

	echo 'Use the "deployer" command to get started..."'
fi

echo 'Done.'
