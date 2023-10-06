#!/bin/bash

# We clear the console
clear

scriptversion="0.0.1"
hysteriaversion="1.0.0"

echo "=========================================================================
|             Fast Hysteria 2 script by @MohsenHNSJ (Github)            |
=========================================================================
|                             Thanks to                                 |
| @SasukeFreestyle (Github) for original tutorial => 'Hysteria2-Iran'|
=========================================================================
Check out the github page, contribute and suggest ideas/bugs/improvments.

========================
| Script version $scriptversion |
========================"

# We want to create a folder to store logs of each action for easier debug in case of an error
# We first must check if it already exists or not
# If it does exist, that means Hysteria is already running and installation is not needed
if [ -d "/FastHysteria2" ]
then
    echo "Hysteria 2 is already configured! Cheking Hysteria version..."
    installedhysteriaversion=$(cat "/FastHysteria2/Version.txt")
    if [ "$installedhysteriaversion" == "$hysteriaversion" ]
    then
            echo "Hysteria 2 is up-to-date!"
            echo "No action is needed, exiting..."
    else 
            echo "Hysteria 2 has updates! updating..."
            # TODO : UPDATE MECHANISM!!!!
    fi
    exit
else
    mkdir /FastHysteria2
fi


echo "=========================================================================
|                       Optimizing server settings                      |
========================================================================="

# We optimise 'sysctl.conf' file for better performance
sudo echo "net.ipv4.tcp_keepalive_time = 90
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_fastopen = 3
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
fs.file-max = 65535000" >> /etc/sysctl.conf

# We optimise 'limits.conf' file for better performance
sudo echo "* soft     nproc          655350
* hard     nproc          655350
* soft     nofile         655350
* hard     nofile         655350
root soft     nproc          655350
root hard     nproc          655350
root soft     nofile         655350
root hard     nofile         655350" >> /etc/security/limits.conf

# We apply the changes
sudo sysctl -p &>> /FastReality/log.txt