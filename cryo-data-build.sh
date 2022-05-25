
set -o errexit
set -o nounset
set -o pipefail
# set -x

function print_usage() {
  echo ""
  echo "./cryo-data.sh path/to/dataset [-h -v]"
  echo "  -v|--verbose: Print verbose messages during processing"
  echo "  -h|--help: print this help"
  echo ""
}

red='\033[0;31m'; orange='\033[0;33m'; green='\033[0;32m'; nc='\033[0m' # No Color
log_info() { echo -e "${green}[$(date --iso-8601=seconds)] [INFO] ${@}${nc}"; }
log_warn() { echo -e "${orange}[$(date --iso-8601=seconds)] [WARN] ${@}${nc}"; }
log_err() { echo -e "${red}[$(date --iso-8601=seconds)] [ERR] ${@}${nc}" 1>&2; }

trap ctrl_c INT # trap ctrl-c and call ctrl_c()
ctrl_c() {
  log_err "CTRL-C caught"
  log_err "No cleaning..."
  # [[ -d ${dest} ]] && (cd ${dest}; rm *_x.tif)
}

debug() { if [[ ${debug:-} == 1 ]]; then log_warn "debug:"; echo $@; fi; }

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
      print_usage; exit 1;;
    -v|--verbose)
      verbose=1; set -o xtrace; shift;;
    *)    # unknown option
      dir+=("$1") # save it in an array for later. 
      shift
      ;;
  esac
done

if [[ -z ${dir:-} ]]; then log_err "Must supply path to dataset"; print_usage; exit 1; fi

function init {
  log_info Initializing...
  if [[ ! -d ./db.dev ]]; then
    log_warn "cryo-data ./db.dev folder not found"
    log_warn "You should probably check out existing cryo-data project with:"
    log_warn "$ datalad clone git@github.com:cryo-data/db ./db.dev"
    log_warn "Or build from scratch (see comments in code)"
    log_err "Exiting..."
    exit 1

    # set up cryo-data
    if [[ 0 ]]; then # Run this manually 1x
      datalad create -D "cryo-data top-level" ./db.dev
      cd ./db.dev
      gh repo create --public -d "cryo-data top-level repository" cryo-data/db
      git remote add origin git@github.com:cryo-data/db
      datalad push --to origin
      # git tag "init"
      # git push -u origin main
      # git push --tag
      # datalad push
      # cd ${CWD}
    fi
  fi
}


function download {
  cd ${dir}
  log_info "Building dataset"
  datalad create -d . -D "${name}" --force
  # datalad save cryo-data.meta cryo-data-download.sh # should maybe be in ".cryo-data" sub-folder?
  git add cryo-data.meta cryo-data-download.sh # should maybe be in ".cryo-data" sub-folder?
  git commit cryo-data.meta cryo-data-download.sh -m "cryo-data meta and download"
  if [[ -e cryo-data-download.sh ]]; then ./cryo-data-download.sh; fi
  if [[ -e cryo-data-download.py ]]; then ./cryo-data-download.py; fi
  cd ${CWD}
}

function upload {  
  cd ${dir}
  log_info "Upload"
  # datalad create-sibling-github --dataset ./10.1594.762898 -s rennermalm cryo-data/rennermalm
  gh repo create --public -d "${name}" cryo-data/${name}
  # undo: gh repo delete cryo-data/${name}
  git remote add origin git@github.com:cryo-data/${name}
  git push -u origin main
  datalad push
  cd ${CWD}
}

function configure {
  log_info "Configure"
  cd ./db.dev
  datalad clone -D $name https://github.com/cryo-data/${name}
  datalad save -r
  datalad push --to origin
  cd $CWD
}


log_info "Working on: ${dir}"
CWD=$(pwd)
name=$(grep "^cryo-data name" ${dir}/cryo-data.meta | cut -d"|" -f2 | tr -d " ")

init
download
upload
configure
