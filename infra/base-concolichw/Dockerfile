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

# Docker image with AFL installed.

FROM hw-fuzzing/base-afl
LABEL MAINTAINER=ccerne@vt.edu

# Putting installation steps in a script reduces the number of intermediate
# layers generated from the Dockerfile
COPY checkout_build_install_concolichw.sh /root/
COPY ConcolicHW /src/concolichw

# This contains patched qsym to work on ubuntu 18.04
#ARG QSYM_REPO_URL="https://github.com/cernec1999/qsym"
#ENV QSYM_REPO_URL ${QSYM_REPO_URL}
RUN /root/checkout_build_install_concolichw.sh
RUN rm /root/checkout_build_install_concolichw.sh

RUN mkdir /src/concolichw/build
RUN cd /src/concolichw/build; CXX=clang++ cmake .. -DCMAKE_BUILD_TYPE=Debug; make -j$(nproc) VERBOSE=1

# Copy over circuit build/fuzz scripts
COPY compile fuzz $SCRIPTS/
