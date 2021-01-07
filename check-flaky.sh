#!/bin/bash

set -ex

BASEDIR=$(dirname "$0")

setup(){
    local num_nodes=${1:-2}

    make cluster-down
    make
    export KUBEVIRT_NUM_NODES=$num_nodes
    make cluster-up
    make push
    make cluster-sync
}

run_tests(){
    local iterations=${1}

    test_ids=$(cat ${BASEDIR}/to-test.txt)
    IFS=$'\n'

    for test_id in ${test_ids}; do
        export FUNC_TEST_ARGS="-focus=${test_id} -v"
        for i in $(seq ${iterations}); do
            echo ======================
            echo "Iteration ${i} of ${iterations}"
            echo ======================
            make functest
        done
    done
}

main(){
    do_setup=
    skip_tests=
    iterations=30
    while getopts ":sni:" opt; do
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
            \? )
                echo "Usage: cmd [-s]"
                ;;
        esac
    done

    if [ ! -z "${do_setup}" ]; then
        setup
    fi
    if [ -z "${skip_tests}" ]; then
        echo iterations: $iterations
        exit 0
        run_tests "${iterations}"
    fi
}

main "${@}"
