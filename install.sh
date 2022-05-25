#!/usr/bin/env bash

set -x

wdir=${1}
name=$(grep "^cryo-data name" ${wdir}/cryo-data.meta | cut -d"|" -f2 | tr -d " ")

for target in author project product repository org misc; do
  dest=$(grep "^${target}" ${wdir}/cryo-data.meta | cut -d"|" -f2 | tr -d " ")
  if [[ "" == ${dest} ]]; then continue; fi
  datalad clone -D $name git@github.com:cryo-data/${name} cryo-data/${target}/${dest}
  (cd cryo-data && datalad save -r && datalad push -r)
done
