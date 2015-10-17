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

# This script will create, load and execute a DBT3 benchmark test for Vector-H.
# It uses the other scripts in this packages to do so.
# It must be run from the Vector-H Master node as a user with db-create permission.

# First create the DBT3 test data
# This should be proportional to the size of the cluster we are running on.

# Default to 100Gb of data per node just to save a bit of time on the first test.
# Move to 1Tb per node for more realistic testing.

# Make sure that our environment is set correctly
if [ -z $II_SYSTEM ]; then
	echo 'Your $II_SYSTEM variable is missing. This means that your environment is not set to allow Vector '
	echo "processes to run. Please initialise it first (typically by running something like '. .ingVHsh') "
	echo "and then run this script again."
	exit 1
fi

DBT3_DB=dbt3_db

# Default to one node, in a start to make this mechanism work for Vector as well as Vector-H
NODES=`cat $II_SYSTEM/ingres/files/hdfs/slaves|wc -l 2>/dev/null`
if [ -z $NODES ]; then
	NODES=1
fi

# change the following number to adjust the data volume being tested. 100 = 100Gb of data per node.
# All of your temp data needs to live on a local disk before it gets loaded, so bear that in mind.
DATA_VOLUME_PER_NODE=1
TOTAL_VOLUME=`expr $DATA_VOLUME_PER_NODE "*" $NODES`
sh dbt3-install.sh $TOTAL_VOLUME

# Create database and load tables with generated data
chmod +x create-ordered-dbt3-schema.sh
./create-ordered-dbt3-schema.sh 

# Now we want to run the queries to test the output. Need the 'runall' script for this, so we have to go and get that
# from Github, as part of the VectorTools package.
echo Making sure we can unzip Tools package
sudo yum install -y unzip wget >/dev/null
wget -nc https://github.com/ActianCorp/VectorTools/archive/master.zip
unzip master.zip

# Defer to separate script for test execution, to make it easier to re-run the tests again
# without getting tangled in one-off setup tasks.

chmod +x run-tests.sh
./run-tests.sh | tee run-$(date +%F.%T).log
