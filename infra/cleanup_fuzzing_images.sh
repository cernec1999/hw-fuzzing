#!/bin/bash -eu
# Copyright 2020 Timothy Trippel
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

# Remove all DUT Docker images
GCP_PROJECT_ID=$(gcloud config get-value project)
FUZZERS="afl-term-on-crash afl sim qsym"
for SOC in $(ls hw/); do
  for DUT in $(ls hw/$SOC/); do
    if [ -d hw/$SOC/$DUT ]; then
      if [[ $DUT != "ot_template" ]]; then
        echo "Cleaning up Docker images for fuzzing: $DUT ..."
        for FUZZER in $FUZZERS; do
          LOWER_CASE_DUT=$(echo $DUT | awk '{print tolower($0)}')
          FUZZER_REGEX="gcr.io/$GCP_PROJECT_ID/$FUZZER-$LOWER_CASE_DUT"
          docker images | grep $FUZZER_REGEX | awk '{print $3}' |
            xargs docker rmi -f || true | >/dev/null
        done
      fi
    fi
  done
done

# Cleanup Docker containers/image layers
docker ps -a -q | xargs -I {} docker rm {}
docker images -q -f dangling=true | xargs -I {} docker rmi -f {}
docker volume ls -qf dangling=true | xargs -I {} docker volume rm {}
