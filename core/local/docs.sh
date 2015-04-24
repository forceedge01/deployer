#!/usr/bin/env bash

Deployer_docs_list() {
	warning 'List all docs'
	ls -la "$localProjectLocation/docs";
}

Deployer_docs_open() {
	warning 'Open file'
	open "$localProjectLocation/docs/$1"
}

Deployer_docs_get() {
	warning 'Download file to docs'
	cd "$localProjectLocation/docs" && curl -O# "$1"
}