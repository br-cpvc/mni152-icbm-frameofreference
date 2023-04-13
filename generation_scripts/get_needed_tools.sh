#/usr/bin/env bash
set -e
cwd=$(pwd)


if [ ! -f "/usr/bin/mnc2nii" ]; then
sudo apt install -y minc-tools
fi

dwndir=downloads
mkdir -p $dwndir
if [ ! -f "$dwndir/c3d-1.0.0-Linux-x86_64.tar.gz" ]; then
wget https://deac-fra.dl.sourceforge.net/project/c3d/c3d/1.0.0/c3d-1.0.0-Linux-x86_64.tar.gz -O $dwndir/c3d-1.0.0-Linux-x86_64.tar.gz
fi
if [ ! -f "$dwndir/c3d-1.0.0-Linux-x86_64.tar.gz.md5sum" ]; then
echo "e27484a8a6ecc9710368c5db41f9d368  c3d-1.0.0-Linux-x86_64.tar.gz" > $dwndir/c3d-1.0.0-Linux-x86_64.tar.gz.md5sum
fi
if [ ! -d "$dwndir/c3d-1.0.0-Linux-x86_64" ]; then
cd $dwndir/
md5sum -c c3d-1.0.0-Linux-x86_64.tar.gz.md5sum
tar xzf c3d-1.0.0-Linux-x86_64.tar.gz
cd $cwd
fi

if [ ! -f "deps/pkg-slicer-cli/output/debian/usr/bin/OrientScalarVolume_new" ]; then
git submodule update --init --recursive
cd deps/pkg-slicer-cli
git submodule update --init
./scripts/build_using_docker.sh
cd ../..
fi
