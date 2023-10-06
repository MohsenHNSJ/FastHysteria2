#!/bin/bash

# We clear the console
clear

scriptversion="0.0.4"
hysteriaversion="1.0.0"
singboxversion="1.5.1"

echo "=========================================================================
|             Fast Hysteria 2 script by @MohsenHNSJ (Github)            |
=========================================================================
|                             Thanks to                                 |
| @SasukeFreestyle (Github) for original tutorial => 'Hysteria2-Iran'|
=========================================================================
Check out the github page, contribute and suggest ideas/bugs/improvments.

==========================
| Script version $scriptversion   |
| Sing-Box version $singboxversion |
=========================="

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
|       Updating repositories and installing the required packages      |
|              (This may take a few minutes, Please wait...)            |
========================================================================="
# We update 'apt' repository 
# We install/update the packages we use during the process to ensure optimal performance
# This installation must run without confirmation (-y)
sudo apt update &> /FastHysteria2/log.txt
sudo apt -y install wget tar openssl gawk sshpass ufw coreutils &>> /FastHysteria2/log.txt

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
sudo sysctl -p &>> /FastHysteria2/log.txt

echo "=========================================================================
|                  Adding a new user and configuring                    |
========================================================================="

# We generate a random name for the new user
choose() { echo ${1:RANDOM%${#1}:1} $RANDOM; }
username="$({ choose 'abcdefghijklmnopqrstuvwxyz'
  for i in $( seq 1 $(( 6 + RANDOM % 4 )) )
     do
        choose 'abcdefghijklmnopqrstuvwxyz'
     done
 } | sort -R | awk '{printf "%s",$1}')"

# We generate a random password for the new user
# We avoid adding symbols inside the password as it sometimes caused problems, therefore the password lenght is high
choose() { echo ${1:RANDOM%${#1}:1} $RANDOM; }
password="$({ choose '123456789'
  choose 'abcdefghijklmnopqrstuvwxyz'
  choose 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  for i in $( seq 1 $(( 18 + RANDOM % 4 )) )
     do
        choose '123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
     done
 } | sort -R | awk '{printf "%s",$1}')"

 # We create a new user
adduser --gecos "" --disabled-password $username &>> /FastHysteria2/log.txt

# We set a password for the new user
chpasswd <<<"$username:$password"

# We grant root privileges to the new user
usermod -aG sudo $username

# We save the new user credentials to use after switching user
# We first must check if it already exists or not
# If it does exist, we must delete it and make a new one to store new temporary data
if [ -d "/temphysteria2folder" ]
then
    rm -r /temphysteria2folder
    sudo mkdir /temphysteria2folder
else
    sudo mkdir /temphysteria2folder
fi

echo $username > /temphysteria2folder/tempusername.txt
echo $password > /temphysteria2folder/temppassword.txt

# We transfer ownership of the temp and log folder to the new user, so the new user is able to add more logs and delete the senstive information when it's no longer needed
sudo chown -R $username /temphysteria2folder/
sudo chown -R $username /FastHysteria2/

echo "=========================================================================
|                      Creating Hysteria 2 service                      |
========================================================================="

# We create a service file
# TODO : UNRESOLVED $MAINPID
sudo echo "[Unit]
Description=sing-box service
Documentation=https://sing-box.sagernet.org
After=network.target nss-lookup.target
[Service]
User=$username
Group=$username
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
ExecStart=/home/$username/hysteria2/sing-box -D /home/$username/hysteria2/ run -c /home/$username/hysteria2/config.json
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/hysteria2.service

echo "=========================================================================
|                           Switching user                              |
========================================================================="
# We now switch to the new user
sshpass -p $password ssh -o "StrictHostKeyChecking=no" $username@127.0.0.1

# We read the saved credentials
tempusername=$(</temphysteria2folder/tempusername.txt)
temppassword=$(</temphysteria2folder/temppassword.txt)

# We delete senstive inforamtion
rm /temphysteria2folder/tempusername.txt
rm /temphysteria2folder/temppassword.txt

# We provide password to 'sudo' command and open port 443
echo $temppassword | sudo -S ufw allow 443

echo "=========================================================================
|               Downloading Sing-Box and required files                 |
========================================================================="

# We create directory to hold Hysteria files
mkdir hysteria2

# We navigate to directory we created
cd hysteria2/

