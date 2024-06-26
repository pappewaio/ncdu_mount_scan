#!/usr/bin/env bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <input_dir_list>"
    exit 1
fi

list_of_indirs="${1}"

if [[ ! -f "${list_of_indirs}" ]]; then
    echo "Error: File '${list_of_indirs}' not found."
    exit 1
fi

project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Read lines from the file into the array
dir_array=()
while IFS= read -r line; do
    dir_array+=("$line")
done < "${list_of_indirs}"

function format_mount_flags() {
  flag="${1}"

  echo "Mounting in folder indir" > /dev/stderr
  for mount in "${dir_array[@]}"
  do
    bn="$(basename ${mount})"
    echo "${bn}" > /dev/stderr
    echo "${flag} ${mount}:/ncdu_mount_scan/indir/${bn} "
  done
}

image_tag="ibp-ncdu_mount_scan-base:"$(cat "docker/VERSION")
singularity_image_tag="ibp-ncdu_mount_scan-base_version-$(cat "docker/VERSION").sif"


FAKE_HOME="/ncdu_mount_scan"
export SINGULARITY_HOME="${FAKE_HOME}"
export APPTAINER_HOME="${FAKE_HOME}"

#echo "${mount_flags}"

if command -v singularity >/dev/null 2>&1; then
  echo "Running using local Singularity..."

  mount_flags=$(format_mount_flags "-B")
  exec singularity shell \
       --contain \
       --cleanenv \
       ${mount_flags} \
       "tmp/${singularity_image_tag}"

elif command -v apptainer >/dev/null 2>&1; then
  echo "Running using local Apptainer..."

  mount_flags=$(format_mount_flags "-B")
  exec singularity shell \
       --contain \
       --cleanenv \
       ${mount_flags} \
       "tmp/${singularity_image_tag}"
else 
  echo "Singularity/Apptainer not found, using Docker..."

  mount_flags=$(format_mount_flags "-v")
  exec docker run \
       --rm \
       -it \
       ${mount_flags} \
       "${image_tag}" \
       /bin/bash
fi
