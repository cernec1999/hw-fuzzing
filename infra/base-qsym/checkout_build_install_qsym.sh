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
QSYM_INSTALL_PACKAGES="git sudo"
apt-get install -y $QSYM_INSTALL_PACKAGES

# Clone QSYM
echo "Checking out QSYM ..."
cd $SRC && git clone --depth 1 $QSYM_REPO_URL

# Build QSYM
cd qsym
./setup.sh
pip install --upgrade virtualenv
virtualenv venv -p /usr/bin/python2.7
source ./venv/bin/activate
pip install .

# Remove installation dependencies to shrink image size\
SUDO_FORCE_REMOVE=yes apt-get remove --purge -y $QSYM_INSTALL_PACKAGES
apt-get autoremove -y
