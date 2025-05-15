#!/bin/bash

set -e

command='( .DockerMatrix.ImageNames[] | select(. == $imageNameOld) ) |= $imageNameNew'

shopt -s nullglob
for package_json in $(find . -name '*.json')
do
  jq "${command}" --arg imageNameOld fleet-os-2 --arg imageNameNew fleet-os-3 ${package_json} > ${package_json}.test
  mv ${package_json}.test ${package_json}
done
shopt -u nullglob