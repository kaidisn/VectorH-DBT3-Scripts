#!/bin/bash
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
