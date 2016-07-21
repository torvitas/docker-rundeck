#!/bin/bash
source /usr/local/src/rundeck/bin/docker.entrypoint.functions.sh

# ensuring everything is where it should be
initRundeck

exec ${@}
