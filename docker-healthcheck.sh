#!/usr/bin/env bash
# Simple docker heatlh check script
#
# Compare output of lpstat -r to see if scheduler is running
# Might consider outputing some debugging information if this fails.

[[ "$(lpstat -r)"  == "scheduler is running" ]]
exit $?
