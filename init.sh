#!/usr/bin/env bash
# add code to bashrc file so deploy can be used

# check if alias exists, if not add it.

declare deployerAlias="dep"

currentDirectory=$(pwd)

if [[ ! -f $currentDirectory/init.sh ]]; then
	echo 'This script needs to run from inside the deployer folder, aborting...'
else
	echo 'Checking for deployer installation...'

	if [[ ! -f /usr/bin/$deployerAlias ]]; then
		echo 'Sorting out file permissions...'
		chmod -R 0777 ./core

		echo 'Creating symlink...'
		sudo ln -s $currentDirectory/core/loader.sh /usr/bin/$deployerAlias

		if [[ ! -f $currentDirectory/config/main.sh ]]; then
			source $currentDirectory/core/vars/core.sh
			echo 'Setup current project'
			cp $currentDirectory/config/$projectFileDistributable $currentDirectory/config/$projectFile
		fi

		echo 'Adding alias reload to bashrc'
		echo 'alias reload="source ~/.bash_profile"' >> ~/.bashrc
        
        echo 'Adding alias project to bashrc'
        echo "alias project=\"reload && cd \$(IFS=' ' read -ra chunks <<< $($deployerAlias p); echo ${chunks[3]})\"" >> ~/.bashrc

        # Change the alias inside files so it works
        sed -i'.bk' s/deployerAlias=.*/deployerAlias=$deployerAlias/ "$currentDirectory/core/loader.sh"
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
			echo "alias $deployerAlias='bash $deployerAlias'" >> ~/.bashrc
			echo '# End of deployer aliases and functions' >> ~/.bashrc
			echo 'Make sure the bashrc file is sourced before using the deployer command';;
		* )
			echo 'Unsupported OS';;
	esac

	source ~/.bashrc
	echo "Use the '$deployerAlias' command to get started..."
fi
echo 'Done.'
