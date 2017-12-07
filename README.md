# Cups docker image

## Description

This is a WIP docker image. While it is still under active development with the internals changing on a regular basis it is useable now. I use it as my print server at work right now.

This image is a bit different from the other cups images on the docker hub in that it does not just use distro packages. I am building cups and cups-filters from source. This means as new versions of cups come out I can update to them quicker. I can also tag out individual releases with this so you can specify your cups version.

If you have a suggestion for how to improve usability of this image, feel free to post on the [github issue tracker](https://github.com/jacobalberty/cups-docker/issues).

## Drivers

CUPS is pretty useless without drivers. Unfortunately it does not come with many drivers in the default install. Your best bet for getting drivers working is to create a dockerfile with this image as the FROM source and install your drivers that way. I am working on a few tools to help make building or installing other drivers easier.

### hplip

I am able to build and install hplip under this image just fine. The debian packages for hplip may work as I do try to provide all of the dependencies to dpkg, I just have not tested that.
I have included a [Dockerfile](https://github.com/jacobalberty/cups-docker/blob/master/examples/hplip/Dockerfile) that installs hplip from source. It does not automatically install the binary plugin.
You will need to use `docker exec` (or the equivalent for your environment) to enter the image and run the `hp-plugin` script in order for the image to be fully functional.

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
