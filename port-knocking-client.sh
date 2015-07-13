#!/bin/bash

# Viet Tran 
# June 2015

# Port knocking client
# Change the ports in the first command to correct chain
# Usage "port-knocking-client destination_ip"


# Define chain of ports to knock
PORTS=(1234 2345 3456 4567)

# Default destination
DEST="147.213.76.130"

if [ ! -z "$1" ]; then DEST=$1; fi

# knocking
for port  in ${PORTS[@]}; do  nc -w 1 -z  $DEST $port; done

