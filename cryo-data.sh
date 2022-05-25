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

function install {
  log_info "Installing DB"
  mkdir -p ${dir}
  # datalad clone git@github.com:cryo-data/cryo-data ${dir}/cryo-data
  datalad clone https://github.com/cryo-data/db ${dir}/db
  (cd ${dir}/db && datalad get -rn *)
}

function build_links {
  log_info "Building local structure"
  for ds in ${dir}/db/*; do
    # echo $ds
    for target in author project product repository org misc; do
      dest=$(grep "^${target}" ${ds}/cryo-data.meta | cut -d"|" -f2 | tr -d " ") || echo ""
      # echo $target $dest
      if [[ ${dest} == "" ]]; then continue; fi # no destination for this target.
      if [[ -e ${target}/${dest} ]]; then continue; fi # already built
      datalad clone ${ds} ${target}/${dest}
    done
  done
}

log_info "Working in ${dir}"
install # from cryo_data github
build_links # build links and structure
