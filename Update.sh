#!/usr/bin/env bash

mkdir tmp{bingner,odyssey,chimera,zebra,installer}/

wget -O tmpbingner/Packages https://apt.bingner.com/dists/ios/1443.00/main/binary-iphoneos-arm/Packages
wget -O tmpodyssey/Packages https://repo.theodyssey.dev/Packages
wget -O tmpchimera/Packages https://repo.chimera.sh/Packages
wget -O tmpzebra/Packages https://getzbra.com/repo/Packages
wget -O tmpinstaller/Packages https://apptapp.me/repo/Packages

for deb in $(grep "mobilesubstrate_\|com.saurik.substrate.safemode_" tmpbingner/Packages | cut -c 11-); do
	wget -nc -P tmpbingner https://apt.bingner.com/${deb}
done
rm tmpbingner/Packages

for deb in $(grep "org.coolstar.sileo_\|org.coolstar.sileobeta_" tmpodyssey/Packages | cut -c 11-); do
	wget -nc -P tmpodyssey https://repo.theodyssey.dev/${deb}
done
rm tmpodyssey/Packages

for deb in $(grep "mobilesubstrate_\|org.coolstar.tweakinject_\|com.ex.substitute_\|libhooker-strap_" tmpchimera/Packages | cut -c 11-); do
	wget -nc -P tmpchimera https://repo.chimera.sh/${deb}
done
rm tmpchimera/Packages

for deb in $(grep "xyz.willy.zebra_" tmpzebra/Packages | cut -c 13-); do
	wget -nc -P tmpzebra https://getzbra.com/repo/${deb}
done
rm tmpzebra/Packages

for deb in $(grep "debs" tmpinstaller/Packages | cut -c 13-); do
	wget -nc -P tmpinstaller https://apptapp.me/repo/${deb}
done
rm tmpinstaller/Packages

for dist in iphoneos-arm64/{substrate,substitute}; do
	arch=iphoneos-arm
	binary=binary-${arch}
	mkdir -p dists/${dist}/main/${binary}
	rm -f dists/${dist}/{Release{,.gpg},main/${binary}/{Packages{,.xz,.zst},Release{,.gpg}}}
	cp -a CydiaIcon*.png dists/${dist}
	
	apt-ftparchive packages pool/main/${dist} > \
		dists/${dist}/main/${binary}/Packages 2>/dev/null
	if [[ "${dist}" == "iphoneos-arm64/substrate" ]]; then
		apt-ftparchive packages ./tmpbingner >> \
			dists/${dist}/main/${binary}/Packages 2>/dev/null
	else
		apt-ftparchive packages ./tmpchimera >> \
			dists/${dist}/main/${binary}/Packages 2>/dev/null
	fi
	apt-ftparchive packages ./tmpodyssey >> \
		dists/${dist}/main/${binary}/Packages 2>/dev/null
	apt-ftparchive packages ./tmpzebra >> \
		dists/${dist}/main/${binary}/Packages 2>/dev/null
	apt-ftparchive packages ./tmpinstaller >> \
		dists/${dist}/main/${binary}/Packages 2>/dev/null
	
	sed -i 's+./tmpbingner+https://apt.bingner.com/debs/1443.00/.+g' dists/${dist}/main/${binary}/Packages
	sed -i 's+./tmpodyssey+https://repo.theodyssey.dev/debs/.+g' dists/${dist}/main/${binary}/Packages
	sed -i 's+./tmpchimera+https://repo.chimera.sh/debs/.+g' dists/${dist}/main/${binary}/Packages
	sed -i 's+./tmpzebra+https://getzbra.com/repo/pkgfiles/.+g' dists/${dist}/main/${binary}/Packages
	sed -i 's+./tmpinstaller+https://apptapp.me/repo/debs/.+g' dists/${dist}/main/${binary}/Packages
	
	xz -c9 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.xz
	zstd -q -c19 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.zst
	
	apt-ftparchive release -c config/${arch}-basic.conf dists/${dist}/main/${binary} > \
		dists/${dist}/main/${binary}/Release 2>/dev/null
	apt-ftparchive release -c config/$(echo "${dist}" | cut -f1 -d '/').conf dists/${dist} > dists/${dist}/Release 2>/dev/null
	
	gpg -abs -u 4CDF62E5176EA441 -o dists/${dist}/Release.gpg dists/${dist}/Release
done

#rm -rf tmp{bingner,odyssey,zebra,installer}/
