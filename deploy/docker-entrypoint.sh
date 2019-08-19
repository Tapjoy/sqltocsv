#!/usr/bin/env bash

set -eux

# "$@" refers to the command-line argument(s) given when this script is called.
# The intended usage of these cli args in our entrypoint scripts is to either call a function
# defined in this script (e.g. `deploy/docker-entrypoint.sh project_exec bash`), or to simply
# pass through the argument supplied. (e.g. `deploy/docker-entrypoint.sh bash`)
ACTION="$@"

# BEGIN FUNCTIONS

## LOCAL ENVIRONMENTS ONLY

# Call the functions that do the necessary work to run your application in a given container,
# and then execute one of the following:
## - CLI arguments passed to the invocation of the `project_exec` function
## - if no CLI arguments provided, run whatever has been defined as the default run target
function project_exec() {
  ###
  # Execute the passed-in command (e.g. `make run`) in the background, which will run as PID 1
  ###
  exec "$@"
}

# END FUNCTIONS

# This is the actual "entry point", by which we mean the invocation that will directly result in PID 1 on the container.
## We will run whatever was passed to the container run command.
## In local development, commands will usually start w/ calls to functions in this script (e.g. `project_exec rake console`)
${ACTION}
