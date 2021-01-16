#!/bin/bash

if [ $(uname) = "Darwin" ]; then
    if [ $(uname -p) = "arm" ] || [ $(uname -p) = "arm64" ]; then
        exit 1
    fi
fi

echo "Subcursus Deployment"
echo ""
echo "I take no responsibility for breaking your phone"
read -p "Press enter to continue"

iproxy 4444 44 >> /dev/null 2>/dev/null &

echo "1 for *OS 14"
echo "2 for *OS 13"
echo "3 for *OS 12"
read version

echo "1 for cydia"
echo "2 for zebra"
echo "3 for sileo"
read packagemanager

rm -rf SubcursusFiles/
mkdir SubcursusFiles
cd SubcursusFiles/

echo '#!/bin/bash' > device.sh
echo '' >> device.sh
echo 'mount -uw -o  union /dev/disk0s1s1' >> device.sh
echo 'rm -rf /etc/profile' >> device.sh
echo 'rm -rf /etc/profile.d' >> device.sh
echo 'rm -rf /etc/alternatives' >> device.sh
echo 'rm -rf /etc/apt' >> device.sh
echo 'rm -rf /etc/ssl' >> device.sh
echo 'rm -rf /etc/ssh' >> device.sh
echo 'rm -rf /etc/dpkg' >> device.sh
echo 'rm -rf /Library/dpkg' >> device.sh
echo 'rm -rf /var/cache' >> device.sh
echo 'rm -rf /var/lib' >> device.sh
echo 'tar --preserve-permissions -xkf bootstrap-ssh.tar -C /' >> device.sh
echo 'snappy -f / -r $(snappy -f / -l | sed -n 2p) -t orig-fs' >> device.sh
echo '/usr/libexec/firmware' >> device.sh
echo 'mkdir -p /etc/apt/sources.list.d/' >> device.sh
echo 'echo "Types: deb" > /etc/apt/sources.list.d/subcursus.sources' >> device.sh
echo 'echo "URIs: https://apt.subcursus.cf/" >> /etc/apt/sources.list.d/subcursus.sources' >> device.sh
echo 'echo "Suites: iphoneos-arm64/substrate" >> /etc/apt/sources.list.d/subcursus.sources' >> device.sh
echo 'echo "Components: main" >> /etc/apt/sources.list.d/subcursus.sources' >> device.sh
echo 'echo "" >> /etc/apt/sources.list.d/subcursus.sources' >> device.sh
if [ "1" = $version ]; then
    echo 'rm /etc/apt/sources.list.d/procursus.sources' >> device.sh
    echo 'echo "Types: deb" > /etc/apt/sources.list.d/procursus.sources' >> device.sh
    echo 'echo "URIs: https://apt.procurs.us/" >> /etc/apt/sources.list.d/procursus.sources' >> device.sh
    echo 'echo "Suites: iphoneos-arm64/1700" >> /etc/apt/sources.list.d/procursus.sources' >> device.sh
    echo 'echo "Components: main" >> /etc/apt/sources.list.d/procursus.sources' >> device.sh
    echo 'echo "" >> /etc/apt/sources.list.d/procursus.sources' >> device.sh
fi
if [ "1" = $packagemanager ]; then
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games apt update' >> device.sh
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games dpkg -r --force-all essential' >> device.sh
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games apt install zstd xz-utils gzip bzip2 libzstd1 -y' >> device.sh
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games dpkg -i packagemanager.deb && apt install essential -y' >> device.sh
else
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games dpkg -i packagemanager.deb' >> device.sh
fi
echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games dpkg -i cameronkatri-keyring_2020.11.21_iphoneos-arm.deb' >> device.sh
echo 'uicache -a' >> device.sh
echo 'echo -n "" > /var/lib/dpkg/available' >> device.sh
echo '/Library/dpkg/info/profile.d.postinst' >> device.sh
if [ "1" = $version ]; then
    echo 'mkdir -p /var/mobile/Library/Application\ Support/xyz.willy.Zebra/' >> device.sh
    echo 'echo "deb https://apt.procurs.us/ iphoneos-arm64/1700 main" >> /var/mobile/Library/Application\ Support/xyz.willy.Zebra/sources.list' >> device.sh
elif [ "2" = $version ]; then
    echo 'echo "deb https://apt.procurs.us/ iphoneos-arm64/1600 main" >> /var/mobile/Library/Application\ Support/xyz.willy.Zebra/sources.list' >> device.sh
elif [ "3" = $version ]; then
    echo 'echo "deb https://apt.procurs.us/ iphoneos-arm64/1500 main" >> /var/mobile/Library/Application\ Support/xyz.willy.Zebra/sources.list' >> device.sh
fi
echo 'echo "deb https://apt.subcursus.cf/ iphoneos-arm64/substrate main" >> /var/mobile/Library/Application\ Support/xyz.willy.Zebra/sources.list' >> device.sh
echo 'touch /.mount_rw' >> device.sh
echo 'touch /.installed_subcursus' >> device.sh
echo 'rm bootstrap-ssh.tar' >> device.sh
echo 'rm packagemanager.deb' >> device.sh
echo 'rm cameronkatri-keyring_*_iphoneos-arm.deb' >> device.sh
echo 'rm device.sh' >> device.sh

if [ "1" = $packagemanager ]; then
    if [ "1" = $version ]; then
        curl -L -o packagemanager.deb https://apt.procurs.us/pool/main/iphoneos-arm64/1700/1600/cydia_1.1.36-1_iphoneos-arm.deb
    elif [ "2" = $version ]; then
        curl -L -o packagemanager.deb https://apt.procurs.us/pool/main/iphoneos-arm64/1600/cydia_1.1.36-1_iphoneos-arm.deb
    elif [ "3" = $version ]; then
        curl -L -o packagemanager.deb https://apt.procurs.us/pool/main/iphoneos-arm64/1500/cydia_1.1.36-1_iphoneos-arm.deb
    fi
elif [ "2" = $packagemanager ]; then
    curl -L -o packagemanager.deb https://getzbra.com/repo/pkgfiles/xyz.willy.zebra_1.1.15_iphoneos-arm.deb
elif [ "3" = $packagemanager ]; then
    curl -L -o packagemanager.deb https://github.com/coolstar/odyssey-bootstrap/raw/master/org.coolstar.sileo_2.0.0b6_iphoneos-arm.deb
fi

if [ "1" = $version ]; then
    curl -L -O https://apt.procurs.us/dists/iphoneos-arm64/1600/bootstrap-ssh.tar.zst -O https://raw.githubusercontent.com/Subcursus/Subcursus.github.io/master/pool/main/iphoneos-arm64/substrate/cameronkatri-keyring_2020.11.21_iphoneos-arm.deb
elif [ "2" = $version ]; then
    curl -L -O https://apt.procurs.us/dists/iphoneos-arm64/1600/bootstrap-ssh.tar.zst -O https://raw.githubusercontent.com/Subcursus/Subcursus.github.io/master/pool/main/iphoneos-arm64/substrate/cameronkatri-keyring_2020.11.21_iphoneos-arm.deb
elif [ "3" = $version ]; then
    curl -L -O https://apt.procurs.us/dists/iphoneos-arm64/1500/bootstrap-ssh.tar.zst -O https://raw.githubusercontent.com/Subcursus/Subcursus.github.io/master/pool/main/iphoneos-arm64/substrate/cameronkatri-keyring_2020.11.21_iphoneos-arm.deb
fi

zstd -d bootstrap-ssh.tar.zst
scp -P4444 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" bootstrap-ssh.tar packagemanager.deb device.sh cameronkatri-keyring_*_iphoneos-arm.deb root@127.0.0.1:/var/root/
ssh -p4444 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" root@127.0.0.1 "bash /var/root/device.sh"

killall iproxy
