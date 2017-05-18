#!/bin/sh
if [ -z $1 ]; then
    echo "Need a version!"
    exit -1
fi
CWD=`pwd`
cd ..
tar -czf dnvme_$1.orig.tar.gz --exclude=debian --exclude-vcs dnvme
cd $CWD
dpkg-buildpackage -uc -us
git clean -xdf
