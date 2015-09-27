Collection of scripts to simplify execution of DBT3 benchmark testing with Actian Vector-H.

This package downloads the DBT3 data generator, generates some test data (defaulting to 1Gb per node for test purposes), creates a schema in a database called dbt3_db with tables that are partitioned appropriately for the cluster it is running on, loads the test data, and executes a concurrent user test with a default of 5 concurrent users and 100 queries. It then reports some status about this run such as the mean, min, max and modal query execution times, and compares your results to a benchmark from a similar run on a 6-node bare-metal cluster.

Default data size is just 1Gb per node, to make the process speedy to execute. To increase this, change the 'DATA_VOLUME_PER_NODE' parameter in the `load-run-dbt3-benchmark.sh script` and then re-run that script.

To start the tests, just run `sh load-run-dbt3-benchmark.sh`.

To re-run the test, just execute `./run-tests.sh`.
Edit that script to change the user or query execution parameters.

To clean up afterwards, delete this folder, `destroydb debt3_db`, and `rm /tmp/runall*`.

To-Do's:
This package has not been tested against single-node Vector, only against Vector-H. It should not be difficult to adapt it to work in a single node, non-Hadoop environment.

For running these tests at larger data sizes on Hadoop, e.g. 1Tb per node, storage of the generated data files will be a problem. For a 15-node cluster, that will need 15Tb on the local node - which is not very practical in most cases. So an enhancement of this package would be to generate data files for each table separately and then move them onto the HDFS area first, before generating the next file. This would reduce the need for intermediate storage space but not eliminate it.

If the files are then stored and loaded from HDFS, this would allow for the usage of `vwload -c` which will load the files in parallel across all nodes, thus greatly speeding up data loading.