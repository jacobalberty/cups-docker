#!/usr/bin/env bash

# The output of lpstat isn't terribly useful for debugging so let's just discard it all for now.
lpstat > /dev/null 2>&1
