#!/usr/bin/env bash
set -ex
script_dir=$(dirname "$0")
cd ${script_dir}/..

echo "building MNI152 ICBM Frame of Reference (FoR) data package"

BUILD_NUMBER=$1
version="1.0.0"

deb_root="build/frameofreference/debian"
#rm -rf ${deb_root}
destdir=${deb_root}/usr/share/
mkdir -p ${destdir}
rsync -a -v --delete data/mni152-icbm-frameofreference ${destdir}

cwd=`pwd`
mkdir -p ${deb_root}/DEBIAN/
cd ${deb_root}
find . -type f ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
cd $cwd

package="mni152-icbm-frameofreference"
maintainer="McConnell Brain Imaging Centre (BIC) of the Montreal Neurological Institute (MNI), McGill University <https://www.bic.mni.mcgill.ca/ServicesAtlases/ICBM152NLin2009>"
arch="all"

#date=`date -u +%Y%m%d`
#echo "date=$date"

#gitrev=`git rev-parse HEAD | cut -b 1-8`
gitrevfull=`git rev-parse HEAD`
gitrevnum=`git log --oneline | wc -l | tr -d ' '`
#echo "gitrev=$gitrev"

buildtimestamp=`date -u +%Y%m%d-%H%M%S`
hostname=`hostname`
echo "build machine=${hostname}"
echo "build time=${buildtimestamp}"
echo "gitrevfull=$gitrevfull"
echo "gitrevnum=$gitrevnum"

debian_revision="${gitrevnum}"
upstream_version="${version}"
echo "upstream_version=$upstream_version"
echo "debian_revision=$debian_revision"

packageversion="${upstream_version}-github${debian_revision}"
packagename="${package}_${packageversion}_${arch}"
echo "packagename=$packagename"
packagefile="${packagename}.deb"
echo "packagefile=$packagefile"

description="build machine=${hostname}, build time=${buildtimestamp}, git revision=${gitrevfull}"
if [ ! -z ${BUILD_NUMBER} ]; then
    echo "build number=${BUILD_NUMBER}"
    description="$description, build number=${BUILD_NUMBER}"
fi

installedsize=`du -s ${deb_root} | awk '{print $1}'`

#for format see: https://www.debian.org/doc/debian-policy/ch-controlfields.html
cat > ${deb_root}/DEBIAN/control << EOF |
Section: science
Priority: extra
Maintainer: $maintainer
Version: $packageversion
Package: $package
Architecture: $arch
Installed-Size: $installedsize
Description: $description
EOF

chmod -R g-w ${deb_root}

echo "Creating .deb file: $packagefile"
rm -f ${package}_*.deb
fakeroot dpkg-deb --build ${deb_root} $packagefile

echo "Package info"
dpkg -I $packagefile
