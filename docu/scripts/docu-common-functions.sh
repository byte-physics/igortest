#!/bin/bash
set -e

require() {
	for cmd in "$@";do
		if ! command -v $cmd > /dev/null; then
				command $cmd
			exit 1
		fi
	done
}

ask_continue() {
	if (($NONINTERACTIVE)); then
		echo "non-interactive mode. Do not continue."
		return 1
	fi
	read -p "Continue [Y/n]" response
	if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
		return 0
	fi
	return 1
}

warning() {
    local logfile=$1
    local progname=$2

    if [ -s "$logfile" ]; then
        echo "warnings occured while executing $progname:"
        cat "$logfile" 1>&2
        if ! ask_continue; then
            exit 1
        fi
    fi
}

# verbose function to show modification time
timediff() {
	local filename="$1"
	local diffmodtime=-1

	diffmodtime=$(( $(date +%s) - $(stat --format=%Y "$filename") ))
	echo "last modification on file \"$filename\" was ${diffmodtime}s ago"
}

# create path variables
SAVED_PWD="$(pwd)"
cleanup() {
	cd "$SAVED_PWD"
}
trap cleanup EXIT

cd ${BASH_SOURCE[0]%/*}
TOP_LEVEL=$(git rev-parse --show-toplevel)
DOCUMENTATION_ROOT="${TOP_LEVEL}/docu"
