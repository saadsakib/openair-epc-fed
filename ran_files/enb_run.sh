DEBUG_LEVEL=""

function print_help() {
  echo "
This program runs lte-softmodem executable
Options
-h | --help
    This help
-d | --debug-level
   Debug level of configuration"
}

    

function run_eNB () {
    until [ -z "$1" ]
    do
        case "$1" in
        -d | --debug-level)
                DEBUG_LEVEL=$2
                shift 2;;
        -h | --help)
                print_help
                exit 1;;
        *)
            print_help
            echo_fatal "Unknown option $1"
            break;;
        esac
    done

    date_dir="`date +%F`"
    log_dir="$OPENAIR_HOME/archives"
    cd $log_dir
    [ -d $date_dir ] || mkdir $date_dir
    log_file="$log_dir/$date_dir/enb_`date +%H_%M`"
    LOG_EXTENSION=".log"

    config="libconfig:$OPENAIR_HOME/ci-scripts/conf_files/lte-tdd-basic-sim-modified.conf"    

    if [ "$DEBUG_LEVEL" != "" ]; then
        config="${config}:dbgl${DEBUG_LEVEL}"
        log_file="${log_file}_debug${DEBUG_LEVEL}"
    else
        echo ""
    fi
    
    log_file="${log_file}${LOG_EXTENSION}"

    # echo "clean ${CLEAN}"
    # echo "config ${config}"
    # echo "log ${log_file}"

    cd $OPENAIR_HOME/cmake_targets/lte_build_oai/build/    
    ENODEB=1 sudo -E ./lte-softmodem -O $config --basicsim > $log_file
}

source oaienv
run_eNB "$@"