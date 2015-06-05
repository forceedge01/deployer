#!/usr/local/env bash

# linux normalizer
function open { xdg-open "$1" &>/dev/null; }
function yesterday { 
	date -d "yesterday" '+%d-%m-%Y'
}