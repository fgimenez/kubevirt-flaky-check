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
    local iterations=${1:-15}

    test_ids=$(cat ${BASEDIR}/to-test.txt)
    IFS=$'\n'

    for test_id in ${test_ids}; do
        export FUNC_TEST_ARGS="-focus=test_id:${test_id}"
        for i in $(seq ${iterations}); do make functest; done
    done
}

main() {
    do_setup=
    while getopts ":s" opt; do
        case ${opt} in
            s )
                do_setup=true
                ;;
            \? )
                echo "Usage: cmd [-s]"
                ;;
        esac
    done

    if [ ! -z "${do_setup}" ]; then
        setup
    fi
    run_tests
}

main
