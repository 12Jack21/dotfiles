#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title My Core Repositories Status
# @raycast.mode inline

# Conditional parameters:
# @raycast.refreshTime 1h

# Optional parameters:
# @raycast.icon ./images/git.png
# @raycast.packageName Git
# @raycast.currentDirectoryPath ~/.config/scripts

# Documentation:
# @raycast.author Jack
# @raycast.authorURL https://github.com/12jack21
# @raycast.description Shows the Git status of my core repositories.

function check_status() {
	local REPO_PATH=$1
	local REPO_NAME=$2
	cd $REPO_PATH

	MESSAGE="$REPO_NAME ($REPO_PATH): "
	ADDED=$(git status --short | grep -c " A")
	if [ $ADDED -gt 0 ]; then
		MESSAGE="   $MESSAGE    \\033[32m   $ADDED Added\\033[0m"
	fi

	MODIFIED=$(git status --short | grep -c " M")
	if [ $MODIFIED -gt 0 ]; then
		MESSAGE="   $MESSAGE    \\033[33m   $MODIFIED Modified\\033[0m"
	fi

	DELETED=$(git status --short | grep -c " D")
	if [ $DELETED -gt 0 ]; then
		MESSAGE="   $MESSAGE    \\033[31m   $DELETED Deleted\\033[0m"
	fi

	UNTRACKED=$(git status --short | grep -c "??")
	if [ $UNTRACKED -gt 0 ]; then
		MESSAGE="   $MESSAGE    \\033[34m   $UNTRACKED Untracked\\033[0m"
	fi

	if [ -z "$MESSAGE" ]; then
		MESSAGE="   No pending changes"
	fi

	echo -e "$REPO_NAME: $MESSAGE"
}

# Display status for each repository
check_status ~/.config ".config"
check_status ~/Documents/OB_Notes "OB_Notes"
check_status ~/Documents/station/zotero_attachment "Zotero Attachment"
