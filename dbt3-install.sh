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

# Be aware that the dbgen program generates all its data into the current folder - which might not be
# large enough on Hadoop systems for really large data sets. Warn the user of this before it's too late.

DATA_VOLUME=""
if [ $# -eq 1 ] ; 	then
	SPACE_NEEDED=$1
	DATA_VOLUME="-s $1"
fi

echo "Downloading and compiling DBT3 Data generator from SourceForge."
wget -nc http://sourceforge.net/projects/osdldbt/files/dbt3/1.9/dbt3-1.9.tar.gz/download >/dev/null
tar xzvf download >/dev/null
cd dbt3-1.9/src/dbgen
make > dbt3-compilation.log 2>&1

if [ -z dbgen ]; then
	echo "Failed to compile data generation tool. Please check that you have a C compiler available on this system."
	exit 1
fi

SPACE_AVAILABLE=`df -Ph $PWD | tail -1 | awk '{ sub(/.$/, "", $3); print $3}'`
if [ $SPACE_AVAILABLE -lt $SPACE_NEEDED ]; then
	echo "Not enough space on this file system to generate all of the test data."
	echo "${SPACE_NEEDED}Gb of space needed and only ${SPACE_AVAILABLE}Gb available."
	echo "Please copy 'dbgen' to a file system with enough space, and then run './dbgen -C 4 $DATA_VOLUME'. "
	exit 1
fi

echo \n \n Generated test data will be created now. You are about to create a lot of data within this file system.
echo "${SPACE_NEEDED}Gb of data will be created next in this directory. Are you sure you want to proceed (y/n) ?"

response=""
read response
if [ $response -eq "n" || $response -eq "N" ] ; then
	echo "Exiting. Please re-run ./dbgen -C 4 $DATA_VOLUME to re-generate the data."
	exit 1
fi

echo "Generating test data now. This will take some time."
echo Starting at `date`
/usr/bin/time -f "%E" ./dbgen -C 4 ${DATA_VOLUME}
echo Completed at `date`