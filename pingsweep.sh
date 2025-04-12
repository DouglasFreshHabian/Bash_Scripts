#!/bin/bash

# A simple bash script that performs a ping sweep

echo "Please enter the subnet:"
read SUBNET

for IP in $(seq 1 254); do
	ping -c 1 $SUBNET.$IP
done
