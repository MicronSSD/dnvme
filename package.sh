#!/bin/sh -x
CWD=`pwd`
cd ..
tar -czf dnvme_$1.orig.tar.gz --exclude=debian --exclude-vcs dnvme
cd $CWD
dpkg-buildpackage -uc -us
