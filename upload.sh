#!/usr/bin/env bash

set -x

wdir=${1}
cd ${wdir}
name=$(grep "^cryo-data name" cryo-data.meta | cut -d"|" -f2 | tr -d " ")
gh repo create --public -d "${name}" cryo-data/${name}
git remote add origin git@github.com:cryo-data/${name}
git push -u origin main
datalad push
