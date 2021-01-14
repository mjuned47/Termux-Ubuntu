#!/bin/sh
clear
echo -e "\x1b[32m\033[1m   #############################################"
echo -e "\x1b[32m #    [ Ubuntu Installation Script by Pro-L!nux ]    #"
echo -e "\x1b[32m   #############################################"
sleep 1
folder="/data/local/tmp/ubuntu"
file="$folder/rootfs-arm64.tar.gz"
if [ -d "$folder" ];
then
        first=1
        echo -e "\x1b[32m [ $folder already exist ]" && sleep 0.5
else
        sleep 1 && echo -e " [ Creating $folder ]"
        mkdir $folder
fi
if [ -f "$file" ] ; then
    sleep 1
    echo -e "\x1b[32m [ rootfs file exists ! ] " && sleep 1
    echo -e "\x1b[32m [ Deleting file ... ] "
    rm "$file" && sleep 1
    echo -e "\x1b[32m [ Done ! ]"
fi
cd $folder
arch=`uname -m`
case "$arch" in
    aarch64|armv8l) arch="arm64" ;;
    armv7l|arm|armhf) arch="armhf" ;;
		*)
			echo -e "\x1b[33m [ Unknown architecture ]"; exit 1 ;;
		esac
echo " [ Device architecture is $arch ]"
sleep 1
echo -e "\x1b[33m [ Downloading Ubuntu 20.10 ($arch)... ]"
wget https://raw.githubusercontent.com/mjuned47/Termux-Rootfs/master/Ubuntu/20.10/$arch/rootfs-$arch.tar.gz
echo -e "\x1b[33m [ Downloaded ! ]"

sleep 1

echo -e "\x1b[33m [ Now Unpacking File... ]"
tar xzf rootfs-$arch.tar.gz
echo -e "\x1b[32m [ Unpacked ! ]"
mkdir $folder/sdcard
mv rootfs-$arch.tar.gz /sdcard

echo -e "\x1b[33m [ Fixing Internet ... ]"

busybox chroot $folder /bin/su - root -c '
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
groupadd -g 3003 aid_inet
groupadd -g 3004 aid_net_raw
groupadd -g 1003 aid_graphics
usermod -g 3003 -G 3003,3004 -a _apt
usermod -G 3003 -a root
'
sleep 1 && echo -e "\x1b[33m [ Done ! ]"
sleep 1
echo -e "\x1b[33m [ Downloaded Ubuntu File has been moved to Internal storage. You can unpack for clean Installation without Downloading ]"
echo -e "\x1b[33m [ To unpack it : go to $folder ]"
echo -e "\x1b[33m [ and type : tar xzf /sdcard/rootfs-$arch.tar.gz ]"
echo -e "\x1b[32m [ Installation Completed,You can mount Ubuntu system ]"
echo -e " [ Ubuntu is installed at $folder ]\e[0m"

sleep 1
