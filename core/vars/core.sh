#!/usr/bin/env bash

declare deployerFile='deploy.conf'
declare projectFileDistributable='project.sh.dist'
declare projectFile='project.sh'
declare deploymentMethod='git'
declare addonsFolder='addons'
declare projectsLog="$DEPLOYER_LOCATION/../logs/projects.log"
declare downloadsFolder="downloads"