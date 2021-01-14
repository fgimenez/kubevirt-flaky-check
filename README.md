# kubevirt-flaky-check

Simple script to run kubevirt tests in a loop.

# Configuration

It accepts these flags:

`-s`: run setup, if present the execution creates and configures the testbed cluster.

`-n`: do not execute tests, just create the testbed cluster.

`-i`: number of iterations to run.

`-t`: tests to execute (ginkgo focus)

# Examples

From kubevirt/kubevirt repo, execute:

```
# Create cluster and execute tests test_id:100 and test_id:200 30 times
/path/to/check-flaky.sh -s -t test_id:100|test_id:200 -i 30

# Execute on previously created cluster all tests in rfe_id:123 60 times
/path/to/check-flaky.sh -t rfe_id:123 -i 60

# Create cluster and execute test_id:100 10 times with provider k8s-1.19
KUBEVIRT_PROVIDER=k8s-1.19 /path/to/check-flaky.sh -s -t test_id:100 -i 10
```
