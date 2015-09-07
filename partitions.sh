#!/bin/bash
# Calculate the default number of partitions to use for large tables for Actian Vector-H.
# Based on the current default of using half of the number of cores in a cluster.
# Run this script only after Vector-H has been successfully installed.
#
# September 7th 2015
# D. Postle

NODES=`cat $II_SYSTEM/ingres/files/hdfs/slaves|wc -l`
CORES=`cat /proc/cpuinfo|grep 'cpu cores'|sort|uniq|cut -d: -f 2`
CPUS=`cat /proc/cpuinfo|grep 'physical id'|sort|uniq|wc -l`
echo `expr $CORES "*" $CPUS "*" $NODES "/" 2`
