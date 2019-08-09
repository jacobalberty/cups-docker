# Cups docker image

## Description

This image provides builds of cups that include a few additional features to make it easier to install and maintain within docker

This image is a bit different from the other cups images on the docker hub in that it does not just use distro packages. I am building cups and cups-filters from source. This means as new versions of cups come out I can update to them quicker. I can also tag out individual releases with this so you can specify your cups version.

If you have a suggestion for how to improve usability of this image, feel free to post on the [github issue tracker](https://github.com/jacobalberty/cups-docker/issues).

## Buster

I have added an experimental buster tag for the current stable and put the release candidates onto buster. 
I will be moving my own installations over to buster asap, once I am confident the stable versions work well I will move the `latest` tag to buster.

## TODO

Things like users are hacky at best and the default configuration for cups does not seem to be particularly suited to docker.
I am accepting any fixes (documentation, patches to source, or patches for the installed configuration) to improve usability.

## Drivers

CUPS is pretty useless without drivers. Unfortunately it does not come with many drivers in the default install.
Your best bet for getting drivers working is to create a dockerfile with this image as the FROM source and install your drivers that way.
To make getting drivers installed easier I will include shell scripts in /usr/local/docker/share/drivers to handle installation of common drivers.
If you manage to get a new driver working please post a description of how you did it on the github issue tracker, or submit a PR.

### hplip

hplip can be installed by running /usr/local/docker/share/drivers/hplip.sh in the image, you must then follow up with running hp-plugin
and accepting the license agreement for a fully working install.

### foomatic

foomatic can be installed by running /usr/local/docker/share/drivers/foomatic.sh in the image. This will only install foomatic-filters and foomatic-db-filters.
To install foomatic-db and foomatic-db-nonfree you will need to follow up with /usr/local/docker/share/drivers/foomatic-db.sh. Eventually once I've tested it and
am satisfied with the foomatic-filters install I may move foomatic-filters into the main buildscript and combine the three db packages into a single install script.

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

### 631/udp
