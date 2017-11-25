# Cups docker image

## Description

This is a WIP docker image. I am publishing it now so if anyone else has a use for it they can modify it for their use.

If you have a suggestion for how to improve usability of this image, feel free to post on the [github issue tracker](https://github.com/jacobalberty/cups-docker/issues).


## Volumes:

### `/config`

This volume contains a couple subfolders.

#### `/config/etc`
This subfolder contains your cups configuration files.

#### `/config/log`
This subfolder contains your log files

#### `/config/init.d` (Optional)
This optional subfolder contains a set of scripts to be run before the cups daemon launches.

## Expose:

### 631/tcp

### 632/udp
