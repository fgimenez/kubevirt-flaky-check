#!/bin/bash

set -e
set -x

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


    while IFS= read -r test_id; do
        export FUNC_TEST_ARGS="-focus=test_id:${test_id}"
        for i in $(seq ${iterations}); do make functest; done
    done < ${BASEDIR}/to-test.txt
}

setup
run_tests
