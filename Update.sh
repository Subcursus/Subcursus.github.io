#!/usr/bin/env bash

if [ $(uname) = "Darwin" ]; then
    SED="gsed"
elif [[ $(uname) = "Linux" ]]; then
    SED="sed"
fi
mkdir tmp{bingner,zebra,installer,bingnersusbstitute}/

wget -O tmpbingner/Packages https://apt.bingner.com/dists/ios/1443.00/main/binary-iphoneos-arm/Packages
wget -O tmpbingnersusbstitute/Packages https://apt.bingner.com/dists/ios/1443.00/main/binary-iphoneos-arm/Packages
wget -O tmpzebra/Packages https://getzbra.com/repo/Packages
wget -O tmpinstaller/Packages https://apptapp.me/repo/Packages

for deb in $(grep "mobilesubstrate_\|com.saurik.substrate.safemode_" tmpbingner/Packages | cut -c 11-); do
    wget -nc -P tmpbingner https://apt.bingner.com/${deb}
done
rm tmpbingner/Packages

for deb in $(grep "com.ex.substitute_\|com.saurik.substrate.safemode_" tmpbingnersusbstitute/Packages | cut -c 11-); do
    wget -nc -P tmpbingnersusbstitute https://apt.bingner.com/${deb}
done
rm tmpbingnersusbstitute/Packages


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
    rm -f dists/${dist}/{InRelease,Release{,.gpg},main/${binary}/{Packages{,.xz,.zst},Release{,.gpg}}}
    cp -a CydiaIcon*.png dists/${dist}

    apt-ftparchive packages pool/main/${dist} > \
        dists/${dist}/main/${binary}/Packages 2>/dev/null
    if [[ "${dist}" == "iphoneos-arm64/substrate" ]]; then
        apt-ftparchive packages ./tmpbingner >> \
            dists/${dist}/main/${binary}/Packages 2>/dev/null
    else
        apt-ftparchive packages ./tmpbingnersusbstitute >> \
            dists/${dist}/main/${binary}/Packages 2>/dev/null
    fi
    apt-ftparchive packages ./tmpzebra >> \
        dists/${dist}/main/${binary}/Packages 2>/dev/null
    apt-ftparchive packages ./tmpinstaller >> \
        dists/${dist}/main/${binary}/Packages 2>/dev/null

    $SED -i 's+./tmpbingnersusbstitute+https://apt.bingner.com/debs/1443.00/.+g' dists/${dist}/main/${binary}/Packages
    $SED -i 's+./tmpbingner+https://apt.bingner.com/debs/1443.00/.+g' dists/${dist}/main/${binary}/Packages
    $SED -i 's+./tmpzebra+https://getzbra.com/repo/pkgfiles/.+g' dists/${dist}/main/${binary}/Packages
    $SED -i 's+./tmpinstaller+https://apptapp.me/repo/debs/.+g' dists/${dist}/main/${binary}/Packages

    xz -c9 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.xz
    zstd -q -c19 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.zst

    apt-ftparchive release -c config/${arch}-basic.conf dists/${dist}/main/${binary} > \
        dists/${dist}/main/${binary}/Release 2>/dev/null
    apt-ftparchive release -c config/$(echo "${dist}" | cut -f1 -d '/').conf dists/${dist} > dists/${dist}/Release 2>/dev/null

    gpg -abs -u 4CDF62E5176EA441 -o dists/${dist}/Release.gpg dists/${dist}/Release
    gpg -abs -u 4CDF62E5176EA441 --clearsign -o dists/${dist}/InRelease dists/${dist}/Release
done

#rm -rf tmp{bingner,odyssey,zebra,installer}/