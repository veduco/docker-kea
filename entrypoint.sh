#!/bin/sh
set -e


#####################
# Set some variables
#####################

claimedLogLevel='INFO'

# Script info
scriptName=$(basename "$0")
loggerName=$(basename "$0" | sed 's/\.sh//')

# Date strings
fileDateString='%Y%m%dT%H%M%SZ'
dateString='%Y-%m-%d %H:%M:%S.%3N'


#####################
# Functions
#####################

log() {
    echo "[$(date -u +"${dateString}")] ${claimedLogLevel}  [${loggerName}] ${1}"
}


#####################
# Body
#####################

log "Starting Kea ${KEA_EXECUTABLE} container"

# Make sure there is no leftover from previous process if it was abruptly
# aborted (power shutdown for instance). Kea does not start if the pid file
# from the previous process still exists.
# https://github.com/JonasAlfredsson/docker-kea/pull/13#discussion_r1309289293
rm -fv /run/kea/*.kea-"${KEA_EXECUTABLE}".pid

# Execute any potential shell scripts in the entrypoint.d/ folder.
find "/entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
    case "${f}" in
        *.sh)
            if [ -x "${f}" ]; then
                log "Launching ${f}";
                "${f}"
            else
                log "Ignoring ${f}, not executable";
            fi
            ;;
        *)
            log "Ignoring ${f}";;
    esac
done

# Feed all the command parameters directly to the defined executable.
exec /usr/sbin/kea-"${KEA_EXECUTABLE}" $@
