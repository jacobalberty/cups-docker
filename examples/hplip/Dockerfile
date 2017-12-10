FROM jacobalberty/cups:latest

ARG DEBIAN_FRONTEND=noninteractive

# This optional build argument overrides the version specified in the script
# ARG HPLIP_VERSION=3.17.11

# Setting this to false will cause the script to not remove any build dependencies
# and leave /home/source in tact
# ARG cleanup=true

RUN /usr/local/docker/share/drivers/hplip.sh
