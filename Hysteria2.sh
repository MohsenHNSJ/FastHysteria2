#!/bin/bash

# We clear the console
clear

scriptversion="0.3.5"

echo "=========================================================================
|             Fast Hysteria 2 script by @MohsenHNSJ (Github)            |
=========================================================================
|                             Thanks to                                 |
| @SasukeFreestyle (Github) for original tutorial => 'Hysteria2-Iran'|
=========================================================================
Check out the github page, contribute and suggest ideas/bugs/improvments.

==========================
| Script version $scriptversion   |
=========================="

echo "=========================================================================
|       Updating repositories and installing the required packages      |
|              (This may take a few minutes, Please wait...)            |
========================================================================="
# We update 'apt' repository 
# We install/update the packages we use during the process to ensure optimal performance
# This installation must run without confirmation (-y)
sudo apt update
sudo apt -y install wget tar openssl gawk sshpass ufw coreutils curl adduser sed grep util-linux

# We check and save the latest version number of Sing-Box
latestsingboxversion="$(curl --silent "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep -Po "(?<=\"tag_name\": \").*(?=\")"  | sed 's/^.//' )"


echo "=========================================================================
|                   Checking for existing installation                  |
========================================================================="

# We want to create a folder to store logs of each action for easier debug in case of an error
# We first must check if it already exists or not
# If it does exist, that means Hysteria 2 is already running and installation is not needed
# We then check the installed version and update it if available
if [ -d "/FastHysteria2" ]
then
    echo "Hysteria 2 is already configured! Cheking version..."
    installedsingboxversion=$(cat "/FastHysteria2/Version.txt")
    if [ "$installedsingboxversion" == "$latestsingboxversion" ]
    then
            echo "Sing-Box is up-to-date!"
            echo "No action is needed, exiting..."
            exit
    else 
            echo "Sing-Box has updates! updating..."
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
echo $latestsingboxversion > /temphysteria2folder/templatestsingboxversion.txt

# We transfer ownership of the temp and log folder to the new user, so the new user is able to add more logs and delete the senstive information when it's no longer needed
sudo chown -R $username /temphysteria2folder/
sudo chown -R $username /FastHysteria2/

echo "=========================================================================
|                      Creating Hysteria 2 service                      |
========================================================================="

# We create a service file
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
ExecReload=/bin/kill -HUP \$MAINPID
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
templatestsingboxversion=$(</temphysteria2folder/templatestsingboxversion.txt)

# We delete senstive inforamtion
rm /temphysteria2folder/tempusername.txt
rm /temphysteria2folder/temppassword.txt
rm /temphysteria2folder/templatestsingboxversion.txt

# We provide password to 'sudo' command and open port 443
echo $temppassword | sudo -S ufw allow 443

echo "=========================================================================
|               Downloading Sing-Box and required files                 |
========================================================================="

# We create directory to hold Hysteria files
mkdir hysteria2

# We navigate to directory we created
cd hysteria2/

# We check and save the hardware architecture of current machine
hwarch="$(uname -m)"

case $hwarch in 
x86_64)
# We check if cpu supprt AVX
avxsupport="$(lscpu | grep -o avx)"

if [ -z "$avxsupport" ];
then 
	echo "AVX is NOT supported"
    hwarch="amd64"
else
	echo "AVX is Supported"
    hwarch="amd64v3"
fi
;;
aarch64)
hwarch="arm64" ;;
armv7l)
hwarch="armv7" ;;
*)
echo "This architecture is NOT Supported by this script. exiting ..."
exit ;;
esac

# We download the latest suitable package for current machine





wget https://github.com/SagerNet/sing-box/releases/download/v$latestsingboxversion/sing-box-$latestsingboxversion-linux-amd64.tar.gz

# TODO : RELOAD AND ENABALE SERVICES (sudo systemctl daemon-reload && sudo systemctl enable hy2)