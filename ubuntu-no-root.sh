#!/bin/sh
clear
echo -e "\x1b[32m\033[1m   ###############################################"
echo -e "\x1b[32m     [ Ubuntu Installation Script by Pro-L!nux ]    "
echo -e "\x1b[32m   ###############################################"

termux_root=/data/data/com.termux/files

echo " [ Checking if wget and proot installed ] "
if [ ! -f "$termux_root/usr/bin/wget" ] ; then 
         echo -e "\x1b[32m [ Installing wget ] " && sleep 1 
         pkg install wget -y && sleep 1
fi

if [ ! -f "$termux_root/usr/bin/proot" ] ; then 
         echo -e "\x1b[32m [ Installing proot ] " && sleep 1 
         pkg install proot -y && sleep 1
fi

arch=`uname -m`
case "$arch" in
    aarch64|armv8l) arch="arm64" ;;
    armv7l|arm|armhf) arch="armhf" ;;
		*)
			echo -e "\x1b[33m [ Unknown architecture ]"; exit 1 ;;
		esac
echo -e "\x1b[32m\033[1m [ Device architecture : $arch ]"

echo -e "\x1b[32m\033[1m [ Download Info : Ubuntu 21.04 $arch ]"

dir=$(pwd)

echo -e "\x1b[32m\033[1m [ Downloading ... ] "
wget https://raw.githubusercontent.com/mjuned47/Termux-Rootfs/master/Ubuntu/21.04/$arch/rootfs-$arch.tar.gz
echo -e "\x1b[33m [ Downloaded ! ]"

mkdir -p $dir/ubuntu-rootfs && cd $dir/ubuntu-rootfs

echo -e "\x1b[32m\033[1m [ Unpacking Rootfs ... ] "
proot --link2symlink tar -xf $dir/rootfs-$arch.tar.gz --exclude='dev'||:

echo -e "\x1b[32m\033[1m [ Fixing Internet ... ] "
echo "nameserver 8.8.8.8" > etc/resolv.conf
echo "nameserver 8.8.4.4" >> etc/resolv.conf
echo "127.0.0.1 localhost" > etc/hosts
cd $dir
mkdir -p binds
bin=start-ubuntu.sh
echo -e "\x1b[32m\033[1m [ Creating $bin ... ]"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)

unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r ubuntu-rootfs"
if [ -n "\$(ls -A binds)" ]; then
    for f in binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo -e "\x1b[32m\033[1m [ Creating excutable ... ] "
chmod +x $bin
 
echo -e "\x1b[32m\033[1m [ Info : internal storage is accessible at /sdcard ] "
echo -e "\x1b[32m\033[1m [ ./start-ubuntu.sh to launch Ubuntu ] "
rm $dir/rootfs-$arch.tar.gz
