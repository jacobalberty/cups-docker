FROM jacobalberty/cups:latest

ARG DEBIAN_FRONTEND=noninteractive

# These optional build arguments override the versions specified in the script
# ARG FOOMATIC_FILTERS_VERSION=4.0.17
# ARG FOOMATIC_DB_ENGINE_VERSION=4.0.13

# Setting this to false will cause the script to not remove any build dependencies
# and leave /home/source in tact
# ARG cleanup=true

RUN /usr/local/docker/share/drivers/foomatic.sh
RUN /usr/local/docker/share/drivers/foomatic-db.sh
