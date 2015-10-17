#!/bin/bash
# Copyright 2015 Actian Corporation
 
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
 
#      http://www.apache.org/licenses/LICENSE-2.0
 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# This script executes the concurrency tests, and can be re-run after the initial test if required.
# Change these initial parameters if you want to vary the tests.

CONCURRENT_USERS=5
TOTAL_QUERIES=100

RUNALL="sh `pwd`/VectorTools-master/runall.sh"
DBT3_DB=dbt3_db

# The query files are in the same folder as this, so just run them now from here.
# We will run them with 10 concurrent users a total of 100 times, so that's an average of 12 times per query
# and then time the results. Output log files are placed in /tmp.

rm /tmp/runall* >/dev/null 2>&1
echo "Beginning execution of tests now. $CONCURRENT_USERS concurrent users, and $TOTAL_QUERIES queries in total across all users."
echo Date/time is now `date`

/usr/bin/time -f "%E" $RUNALL -d $DBT3_DB -g N -i $II_SYSTEM -k Y -m $CONCURRENT_USERS -n $TOTAL_QUERIES -p N -s .

echo Completed run at `date`

echo "Summary of runtime output is as follows:"

# Note that this awk script only works if the SQL scripts have got an \rt line at the top to produce
# the timing info in the log files for us to analyse.

awk -f runall-stats.awk /tmp/runall*log

echo By way of comparison, this test using Vector-H 4.2.1 with 1Gb of data per node, 5 concurrent users and 100 
echo queries completes in around 45 seconds on a 6 data-node, bare-metal cluster with 16 cores per node and 
echo 256Gb RAM on each node.

echo This run completed in `cat run_performance.out` of this time, where less than 100% is faster.
