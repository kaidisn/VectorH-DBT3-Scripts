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

# Validate that the VectorH installation is present and running.
# This script logs into each node and checks that the main installation locations are present.

cmd=${1}
if [ "${cmd}" = "" ]
then
	cmd="hostname -f >> /tmp/$$.out;/usr/bin/hdfs dfs -ls / >> /tmp/$$.out; cat /tmp/$$.out; rm -f $$.out"
fi

. ~/.ingVHsh # Assumed to be available in HOME directory
PBS_NODEFILE="/tmp/nodefile.srt"
cat ${II_SYSTEM}/ingres/files/hdfs/slaves | sort > ${PBS_NODEFILE}
numprocs=`cat ${PBS_NODEFILE} | wc -l`
mpirun -n ${numprocs} -machinefile ${PBS_NODEFILE} bash -c "${cmd}"
