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

# Calculate the default number of partitions to use for large tables for Actian Vector-H.
# Based on the current default of using half of the number of cores in a cluster.
# Run this script only after Vector-H has been successfully installed.
#
# September 7th 2015
# D. Postle

# Default number of nodes to 1, in case this is running with single-node Vector, not Vector-H
NODES=`cat $II_SYSTEM/ingres/files/hdfs/slaves|wc -l 2>/dev/null`
if [ -z $NODES ]; then
	NODES=1
fi

CORES=`cat /proc/cpuinfo|grep 'cpu cores'|sort|uniq|cut -d: -f 2`
CPUS=`cat /proc/cpuinfo|grep 'physical id'|sort|uniq|wc -l`
PARTITIONS=`expr $CORES "*" $CPUS "*" $NODES "/" 2`

# Default partitions to 2 where calc yields 0 or 1 
if [ "$PARTITIONS" -lt "2" ]; then
    PARTITIONS=2
fi

echo $PARTITIONS

