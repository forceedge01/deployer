#!/usr/bin/env bash
# add code to bashrc file so deploy can be used

# check if alias exists, if not add it.

declare deployerAlias="dep"
declare auxilary="${HOME}/.bashrc_deployer_auxilary"
declare mainFile="${HOME}/.bashrc"
declare installationDirectory="/usr/local/bin"

currentDirectory=$(pwd)

if [[ ! -f $currentDirectory/init.sh ]]; then
	echo 'This script needs to run from inside the deployer folder, aborting...'
elif [[ ! -f $mainFile ]]; then
	echo "$mainFile file not found!"
else
	echo 'Checking for deployer installation...'

	echo 'Creating $auxilary file'
	touch $auxilary

	if [[ ! -f $installationDirectory/$deployerAlias ]]; then
		echo 'Sorting out file permissions...'
		chmod -R 0777 ./core

		echo 'Creating symlink...'
		if [[ ! -d $installationDirectory ]]; then
			echo ">>> ERROR: Directory $installationDirectory does not exist!"

			return;
		fi

		sudo ln -s $currentDirectory/core/loader.sh $installationDirectory/$deployerAlias

		if [[ $? != 0 ]]; then
			echo "ERROR>>> Was unable to create symlink! Check permissions on $installationDirectory"
		fi

		if [[ ! -f $currentDirectory/config/main.sh ]]; then
			source $currentDirectory/core/vars/core.sh
			echo 'Setup current project'
			cp $currentDirectory/config/$projectFileDistributable $currentDirectory/config/$projectFile
		fi

		echo 'Adding alias reload to bashrc'
		echo "alias reload='source $mainFile'" >> $auxilary

        echo 'Adding alias project to bashrc'
        echo "alias project=\"reload && cd \$(IFS=' ' read -ra chunks <<< \$($deployerAlias p); echo \${chunks[3]})\"" >> $auxilary

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
			echo '# Deployer aliases' >> $auxilary
			echo "alias $deployerAlias='bash $deployerAlias'" >> $auxilary
			echo '# End of deployer aliases and functions' >> $auxilary
			echo 'Make sure the bashrc file is sourced before using the deployer command';;
		* )
			echo 'Unsupported OS';;
	esac

	echo "Adding $auxilary file path to $mainFile";
	echo "source $auxilary" >> "$mainFile"

	source "$mainFile"
	echo "Use the '$deployerAlias' command to get started..."
fi
echo 'Done.'
