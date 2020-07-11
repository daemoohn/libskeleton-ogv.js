#!/bin/bash

## getting the source code
git clone https://github.com/brion/libskeleton.git

## et a random version tag
cd libskeleton
version="no-tag"
cd ..

## verify if this specific version has already been uploaded to bintray
bintray_response=`curl -u$1:$2 https://api.bintray.com/packages/daemoohn/libskeleton-ogv.js/libskeleton-ogv.js/versions/$version`
if [[ $bintray_response != *"Version '$version' was not found"* ]]; then
  curl -X DELETE -u$1:$2 https://api.bintray.com/packages/daemoohn/libskeleton-ogv.js/libskeleton-ogv.js/versions/$version
fi

## configureSkeleton.sh
cd libskeleton
if [ ! -f configure ]; then
  # generate configuration script
  sed -i.bak 's/$srcdir\/configure/#/' autogen.sh
  ACLOCAL_PATH="$dir/build/js/root/share/aclocal" ./autogen.sh
fi
cd ..

## compileSkeletonJs.sh
dir=`pwd`

# set up the build directory
mkdir -p build
cd build

mkdir -p js
cd js

mkdir -p root
mkdir -p libskeleton
cd libskeleton

# finally, run configuration script
emconfigure ../../../libskeleton/configure \
	--prefix="$dir/build/js/root" \
	PKG_CONFIG_PATH="$dir/build/js/root/lib/pkgconfig" \
	--disable-shared

# compile libskeleton
emmake make -j4 || exit 1
emmake make install || exit 1

cd $dir/build/js/root

## upload to bintray
zip -r $dir/libskeleton-ogv.js.zip . 
curl -T $dir/libskeleton-ogv.js.zip -u$1:$2 https://api.bintray.com/content/daemoohn/libskeleton-ogv.js/libskeleton-ogv.js/$version/libskeleton-ogv.js.zip?publish=1
