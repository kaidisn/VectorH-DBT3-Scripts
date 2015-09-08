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

wget http://sourceforge.net/projects/osdldbt/files/dbt3/1.9/dbt3-1.9.tar.gz/download
tar xzvf dbt3-1.9.tar.gz
cd dbt3-1.9/src/dbgen
make
./dbgen
