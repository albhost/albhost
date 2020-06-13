#!/bin/sh
if [ -e ezserver.ffmpeg.tar ]; then
rm -f ezserver.ffmpeg.tar
fi
read  -p "Please enter installation password? " dpass
if test -z $dpass; then
exit 0
fi
if which ifconfig>/dev/null; then
echo "ifconfig existed"
else
echo "ifconfig installing"
apt-get install net-tools
echo "ifconfig installed sucessfully..."
fi
standard_url='http://www.ezhometech.com/download_ffmpeg_'$dpass'/ezserver.ffmpeg.tar'
wget -O ezserver.ffmpeg.tar $standard_url
if [ -s ezserver.ffmpeg.tar ]; then
	echo "ezserver ffmpeg version downloaded..."
	if [ -e ezserver_ffmpeg ]; then
		backupfilename="ezserver_ffmpeg_$(date +%Y%m%d_%s)"
		read  -p "Backup current ezserver_ffmpeg folder(?(y/n) " yn
		if [ "$yn" != "Y" ] && [ "$yn" != "y" ]; then
			rm -rf ezserver_ffmpeg
			echo "Remove ezserver_ffmpeg folder"				
		else
			mv ezserver_ffmpeg $backupfilename
			echo "Backup ezserver_ffmpeg folder to "$backupfilename		
		fi
	fi
	tar xfvz ezserver.ffmpeg.tar
	rm ezserver.ffmpeg.tar
else
	echo "Password Error..."
	exit 0
fi
cd ezserver_ffmpeg
chmod 777 *.*
chmod 777 *
echo 2062780 > /proc/sys/kernel/threads-max
if ! cat /etc/sysctl.conf | grep -v grep | grep -c 1677721600 > /dev/null; then 
echo 'net.core.wmem_max= 1677721600' >> /etc/sysctl.conf
echo 'net.core.rmem_max= 1677721600' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem= 1024000 8738000 1677721600' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem= 1024000 8738000 1677721600' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_timestamps = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_sack = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_no_metrics_save = 1' >> /etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 5000' >> /etc/sysctl.conf
echo 'net.ipv4.route.flush=1' >> /etc/sysctl.conf
echo 'fs.file-max=65536' >> /etc/sysctl.conf
sysctl -p
fi
ezgetconfig_image="./ezgetconfig"
#
# 1. Type network interface
#
network_interface_str="network_interface"
network_interface_value=$("$ezgetconfig_image"  $network_interface_str)
rm -rf serial_number.txt
echo "1. Please input network interface name:"
ifconfig -a -s|cut -d' ' -f1|tail -n +2
while [ 1 ]
do
	read  -p "--> " ni
	if test -z $ni; then
		echo "1. Please input network interface name:"
		ifconfig -a -s|cut -d' ' -f1|tail -n +2
	else
		break
	fi
done
sedcmd='s/'$network_interface_value'/'$ni'/g'
sed -i $sedcmd ezserver_config.txt
echo "Set iface to "$ni

ezserver_folder="$PWD"
sed -i '3d' monitor.sh
sed -i '2a\''export EZSERVER_DIR="'"$ezserver_folder"'"' monitor.sh

echo "4. Ezserver installation successfully..."
cd ezserver_ffmpeg
./start.sh



