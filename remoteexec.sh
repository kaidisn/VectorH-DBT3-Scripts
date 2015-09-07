#!/bin/bash

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
