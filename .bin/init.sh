#!/usr/bin/env bash

# Initialize the cryo-data datalad sibling repositories


# load pre.sh commands
DIR=$(dirname $(readlink -f $0))
source ${DIR}/pre.sh

log_info Initializing...
if [[ ! -d ./database ]]; then
  log_warn "cryo-data ./database folder not found"
  log_warn "You should probably check out existing cryo-data project with:"
  log_warn "$ datalad clone git@github.com:cryo-data/database ./database"
  log_warn "Or build from scratch (see comments in code)"
  log_err "Exiting..."
  exit 1
  
  # set up cryo-data
  if [[ 0 ]]; then # Run this manually 1x
    datalad create -D "cryo-data database" ./database
    cd ./database
    gh repo create --public -d "cryo-data top-level database" cryo-data/database
    git remote add origin git@github.com:cryo-data/database
    datalad push --to origin
  fi
fi 

for aka in $(yq '.aka | keys' ./template/cryo-data.yaml | cut -d" " -f2); do
  ## Fetch
  log_info "Checking for ${aka}"
  if [[ -d ${aka} ]]; then
    log_info "${aka} found"
  else
    log_warn "${aka} not found. Cloning..."
    datalad clone -d . git@github.com:cryo-data/${aka} ./${aka}
    # log_warn "${aka} not found. Installing..."
    # datalad install -d . git@github.com:cryo-data/${aka} ./${aka}
    ## Create
    # log_warn "${aka} not found. Creating..."
    # datalad create -D "cryo-data ${aka}" ./${aka}
    # cd ./${aka}
    # gh repo create --public -d "cryo-data top-level ${aka}" cryo-data/${aka}
    # git remote add origin git@github.com:cryo-data/${aka}
    # datalad push --to origin
    # cd ..
  fi
  
done

