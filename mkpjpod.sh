#!/usr/bin/env bash
# Copyright 2020 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Usage: mkpj.sh --job=foo ...
#
# Arguments to this script will be passed to a dockerized mkpj, the output
# of which will then be piped through a dockerized mkpod. Intended solely
# for development/debugging purposes, to schedule a prowjob's resulting pod
# directly to a build cluser without using the prow control plane
#
# Example Usage:
# config/mkpjpod.sh --job=post-test-infra-push-bootstrap | kubectl --context=build-cluster create -f -
# (type "master" at the Base ref prompt)
#
# NOTE: kubectl should be pointed at the prow build cluster you intend
# to create the prowjob's pod in!

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
config="${root}/config/prow/config.yaml"
job_config_path="${root}/config/jobs"

docker run -i --rm \
  -v "${root}:${root}:z" \
  gcr.io/k8s-prow/mkpj "--config-path=${config}" "--job-config-path=${job_config_path}" "$@" | \
docker run -i --rm \
  -v "${root}:${root}:z" \
  gcr.io/k8s-prow/mkpod "--build-id=snowflake" "--prow-job=-"
