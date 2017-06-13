# Actian Vector/H DBT3 performance test kit

Collection of scripts to simplify execution of DBT3 benchmark testing with Actian Vector and VectorH.

This package downloads the DBT3 data generator, generates some test data (defaulting to 1Gb per node for test purposes), creates a schema in a database called dbt3_db with tables that are partitioned appropriately for the cluster it is running on, loads the test data, and executes a concurrent user test with a default of 5 concurrent users and 100 queries. It then reports some status about this run such as the mean, min, max and modal query execution times, and compares your results to a benchmark from a similar run on a 6-node bare-metal cluster.

Default data size is just 1Gb per node, to make the process speedy to execute. To increase this, change the 'DATA_VOLUME_PER_NODE' parameter in the `load-run-dbt3-benchmark.sh script` and then re-run that script.

To start the tests, just run `sh load-run-dbt3-benchmark.sh`.

To re-run the test, just execute `./run-tests.sh`.
Edit that script to change the user or query execution parameters.

Example of final output:
```
0:14.62
Completed run at Tue Jun 13 19:44:12 UTC 2017
Summary of runtime output is as follows:
Minimum query execution time was 0.029170
Maximum query execution time was 0.471352
Mean query execution time was 0.147187
Median query execution time was 0.116514
Total execution time for all queries was 12.9525
Range of bucket  1  is  0.029170  to  0.041260
Range of bucket  2  is  0.041260  to  0.079579
Range of bucket  3  is  0.079579  to  0.095639
Range of bucket  4  is  0.095639  to  0.111626
Range of bucket  5  is  0.111626  to  0.117624
Range of bucket  6  is  0.117624  to  0.121202
Range of bucket  7  is  0.121202  to  0.125697
Range of bucket  8  is  0.125697  to  0.148513
Range of bucket  9  is  0.148513  to  0.426352
Range of bucket  10  is  0.426352  to  0.471352
```

To clean up afterwards, delete this folder, `destroydb dbt3_db`, and `rm /tmp/runall*`.

For running these tests at larger data sizes on Hadoop, e.g. 1Tb per node, storage of the generated data files will be a problem. For a 15-node cluster, that will need 15Tb on the local node - which is not very practical in most cases. So an enhancement of this package would be to generate data files for each table separately and then move them onto the HDFS area first, before generating the next file. This would reduce the need for intermediate storage space but not eliminate it.

Alternatively, data file generation could be immediately streamed into HDFS via cat, to avoid the local filesystem altogether.

If the files are then stored and loaded from HDFS, this would allow for the usage of `vwload -c` which will load the files in parallel across all nodes, thus greatly speeding up data loading.
