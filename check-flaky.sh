#!/bin/bash

set -ex

DEFAULT_ITERATIONS=30
DEFAULT_NUM_NODES=2

setup(){
    local num_nodes=${1:-${DEFAULT_NUM_NODES}}

    make cluster-down
    make
    export KUBEVIRT_NUM_NODES=$num_nodes
    make cluster-up
    make push
    make cluster-sync
}

run_iterations(){
    local iterations=${1}
    local focus=${2}

    if [ ! -z "${focus}" ]; then
        export FUNC_TEST_ARGS="-focus=${focus} -v"
    fi
    for i in $(seq ${iterations}); do
        info "Iteration ${i} of ${iterations}"
        make functest
    done
}

run_tests(){
    local test_ids_in=${1}
    local iterations=${2:-${DEFAULT_ITERATIONS}}

    if [ -z "${test_ids_in}" ]; then
        run_iterations "${iterations}"
    fi

    IFS=',' read -ra test_ids <<< "${test_ids_in}"
    for test_id in "${test_ids[@]}"; do
        info "Running tests with focus ${test_id}"
        run_iterations "${iterations}" "${test_id}"
    done
}

info(){
    local msg=${1}
    set +x
    echo ===============================
    echo "${msg}"
    echo ===============================
    set -x
}
usage(){
    echo "Usage: check-flaky [-t <test_id1,test_id2,...>] [-s] [-n] [-i iterations]"
}

main(){
    do_setup=
    skip_tests=
    iterations=30
    test_ids_in=
    while getopts ":sni:t:" opt; do
        case $opt in
            s )
                do_setup=true
                ;;
            n )
                do_setup=true
                skip_tests=true
                ;;
            i )
                iterations=${OPTARG}
                ;;
            t )
                test_ids_in=${OPTARG}
                ;;
            \? )
                usage
                ;;
        esac
    done
    shift "$((OPTIND-1))"

    if [ ! -z "${do_setup}" ]; then
        setup
    fi
    if [ -z "${skip_tests}" ]; then
        run_tests "${test_ids_in}" "${iterations}"
    fi
}

main "${@}"
