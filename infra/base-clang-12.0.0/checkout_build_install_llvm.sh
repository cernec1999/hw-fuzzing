#!/bin/bash -eux
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install dependencies
LLVM_DEP_PACKAGES="\
    cmake \
    git \
    ninja-build \
    python2.7 \
    libssl-dev \
    binutils-gold \
    binutils-dev \
    wget"
apt-get update
apt-get install -y $LLVM_DEP_PACKAGES

# Download CMake version 3.21.2
wget https://github.com/Kitware/CMake/releases/download/v3.21.2/cmake-3.21.2.tar.gz -O /tmp/cmakesrc.tar.gz
tar -xvf /tmp/cmakesrc.tar.gz -C /tmp/
rm -rf /tmp/cmakesrc.tar.gz
cd /tmp/cmake-3.21.2
./bootstrap
make -j$(nproc)
make install

# Download LLVM version 12.0.0

# Download and unpack LLVM
cd $SRC
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/llvm-12.0.0.src.tar.xz
tar xf llvm-12.0.0.src.tar.xz
mv llvm-12.0.0.src llvm

# Download and unpack Clang
cd $SRC/llvm/tools
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/clang-12.0.0.src.tar.xz
tar xf clang-12.0.0.src.tar.xz
mv clang-12.0.0.src clang

# Download and unpack Clang runtime library
cd $SRC/llvm/projects
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/compiler-rt-12.0.0.src.tar.xz
tar xf compiler-rt-12.0.0.src.tar.xz
mv compiler-rt-12.0.0.src compiler-rt

# Download and unpack libc
cd $SRC/llvm/projects
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/libcxx-12.0.0.src.tar.xz
tar xf libcxx-12.0.0.src.tar.xz
mv libcxx-12.0.0.src libcxx

# Download and unpack libc ABI
cd $SRC/llvm/projects
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/libcxxabi-12.0.0.src.tar.xz
tar xf libcxxabi-12.0.0.src.tar.xz
mv libcxxabi-12.0.0.src libcxxabi

# Build & install
mkdir -p /tmp/llvm
cd /tmp/llvm
cmake -G "Ninja" \
  -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
  -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
  -DLLVM_FORCE_ENABLE_STATS=ON -DLLVM_BINUTILS_INCDIR=/usr/include $SRC/llvm
ninja -j$(nproc)
ninja install
rm -rf /tmp/llvm

# Cleanup
cd /
rm -rf $SRC/llvm-12.0.0.src.tar.xz
rm -rf $SRC/llvm
apt-get remove --purge -y $LLVM_DEP_PACKAGES
apt-get autoremove -y
