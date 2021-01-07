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
    local iterations=${1:-30}

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


do_setup=
skip_tests=
while getopts ":sn" opt; do
    case $opt in
        s )
            do_setup=true
            ;;
        n )
            do_setup=true
            skip_tests=true
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
    run_tests
fi
