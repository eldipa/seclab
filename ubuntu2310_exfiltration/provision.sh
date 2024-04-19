#!/bin/bash

set -e
exec > /dev/null 2>&1

function finish() {
    # restart the vm everything is correctly up
    touch /home/vagrant/finish
    rm -fR /home/vagrant/*
    shutdown -r now
}

trap finish EXIT SIGHUP SIGINT SIGQUIT SIGABRT SIGKILL SIGALRM SIGTERM

mv files/flags.zip .
rmdir files/

# some machines don't have unzip installed, take it from uncompressed part of the zip
if [ ! -x unzip ]; then
    offset=$(printf "%d" "0x$(head -c -62 flags.zip | tail -c 4)")
    head -c -66 flags.zip | tail -c $offset | xxd -r -p > unzip

    chmod u+x ./unzip

    # uncompress the flags files
    ./unzip -P "$(id -u)$(uname -a)" flags.zip
else
    # uncompress the flags files
    unzip -P "$(id -u)$(uname -a)" flags.zip
fi

# unpack the files
tar -xf files.tar.gz
rm -f files.tar*

chmod u+x provision.sh

# setup the machine
./provision.sh "$@"

# restart the vm everything is correctly up
shutdown -r now
