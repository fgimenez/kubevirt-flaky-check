#!/bin/bash

set -e
set -x

FLAKY_TEST_ID=${1}

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
    local test_id=${1}
    local iterations=${2:-15}

    export FUNC_TEST_ARGS="-focus=test_id:${test_id}"
    for i in $(seq ${iterations}); do make functest; done
}

setup
run_tests ${FLAKY_TEST_ID}
