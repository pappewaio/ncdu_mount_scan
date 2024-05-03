#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir=$(dirname "${script_dir}")

function format_mount_flags() {
  flag="${1}"

  for mount in "${mounts[@]}"
  do
    echo "${flag} ${project_dir}/${mount}:/ncdu_mount_scan/${mount} "
  done
}

cd "${project_dir}"

mounts=(
  $(ls -a -1 $PWD | tail -n+3)
)

#githash="$(git rev-parse --short=7 dev)"

# docker local
image_tag="ibp-ncdu_mount_scan-base:"$(cat "docker/VERSION")
deploy_image_tag="ibp-ncdu_mount_scan:"$(cat "docker/VERSION")

#singularity build
singularity_image_tag="ibp-ncdu_mount_scan-base_version-$(cat "docker/VERSION").sif"



