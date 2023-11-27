#!/bin/bash

# A Simple Bash Script to Automate the Gathering of Detailed Information On Amd GPU

LOGDIR=/home/douglas/AMD/LOGS/$(date +%F)
mkdir -p $LOGDIR
cd $LOGDIR

# Gather Basic Configuration Details

sudo lshw -c cpu | grep product >> basic.conf
lspci -nn | grep "AMD" >> basic.conf
sudo dmidecode -t BIOS | grep Version >> basic.conf
lsb_release -sd >> basic.conf
uname -a >> basic.conf
dkms status >> basic.conf

# Create Detailed Log Files

dkms status > dkms.status.log
lsmod | grep amdgpu > lsmod.amdgpu.log
sudo dmesg > dmesg.log
type -p dpkg && dpkg -l > package.log

# In Depth Analysis

lspci -vnn > lspci.vnn.log
lspci -nn > lspci.nn.log
sudo dmidecode > dmidecode.log
uname -a > uname.a.log
lsinitramfs /boot/initrd.img-`uname -r` > lsinitramfs.log
sudo lshw > lshw.log
modinfo amdgpu > modinfo.amdgpu.log
glxinfo > glxinfo.log
