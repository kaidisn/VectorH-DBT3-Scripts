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

# Retrieve the DBT3 test data generator scripts, unpack and execute them
# Run the generator to create a one gigagyte set of data files.

# To create more, just run:
# ./dbgen -s 10
# to create a set of 10gb data files - and increase the number for more.
# Script now can take a parameter to determine what volume of data to generate
# Should typically be based on the number of nodes in the cluster, but we leave
# that decision to the caller.

# Be aware that the dbgen program generates all its data into /tmp - which might not be
# large enough on Hadoop systems for really large data sets.

DATA_VOLUME=""
if [ $# -eq 1 ] ; 	then
	DATA_VOLUME="-s $1"
fi

wget -nc http://sourceforge.net/projects/osdldbt/files/dbt3/1.9/dbt3-1.9.tar.gz/download
tar xzvf download
cd dbt3-1.9/src/dbgen
make >/dev/null

if [ -z dbgen ]; then
	echo "Failed to compile data generation tool. Please check that you have a C compiler available on this system."
fi

sh dbgen ${DATA_VOLUME}
