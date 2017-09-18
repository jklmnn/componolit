#!/bin/bash -ev

export PATH=${PATH}:/usr/local/bin

# Download and install Genode toolchain
curl -O -J -L https://sourceforge.net/projects/genode/files/genode-toolchain/17.05/genode-toolchain-17.05-x86_64.tar.xz
sudo tar -xf genode-toolchain-17.05-x86_64.tar.xz -C /

# Checkout Genode and genode-world
git clone --depth=50 --branch componolit-stable https://github.com/Componolit/genode.git ci/src
git clone --depth=50 https://github.com/genodelabs/genode-world.git ci/src/repos/world
ln -sf ../../.. ci/src/repos/componolit

# Prepare required ports
./ci/src/tool/ports/prepare_port core googletest libc stdcxx dlmalloc libart liblz4 liblzma libnativehelper valgrind nova lwip zlib

# Create build directory
./ci/src/tool/create_builddir x86_64 BUILD_DIR=./ci/build/

# Copy/change config files
cp ./ci/build.conf ./ci/build/etc/
cp ./ci/tools.conf ./ci/build/etc/
sed -i -e "s-__GENODE_DIR__-$(pwd)/ci/src-" ./ci/build/etc/build.conf

# Run all tests
cd ./ci/build/
../src/repos/componolit/tool/alltests
