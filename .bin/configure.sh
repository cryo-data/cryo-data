#!/usr/bin/env bash

# Make a cryo-data dataset a child of the database, and then of all relevant akas

# load pre.sh
DIR=$(dirname $(readlink -f $0))
source ${DIR}/pre.sh

# # make child of database
# log_info "Configure database"
# cd ./database
# datalad clone -D $name https://github.com/cryo-data/${name}
# datalad save -r
# datalad push --to origin
# cd $CWD

# make child of all akas
for key in $(yq '.aka | keys' ${dir}/cryo-data.yaml | cut -d" " -f2); do
  val=$(yq ".aka.${key}" ${dir}/cryo-data.yaml)
  if [[ ${val} == "" ]]; then continue; fi
  log_info "Linking ${name} to ${key}/${val}"
  datalad clone -D ${name} https://github.com/cryo-data/${name} ${key}/${val}
  datalad save -r
done
datalad push -r --to origin
