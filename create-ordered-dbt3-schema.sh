#!/bin/bash
# Copyright 2017 Actian Corporation

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at

#      http://www.apache.org/licenses/LICENSE-2.0

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# Script to create a DBT3 test database then create the tables, with reasonable default partitions.
# Then we load the data from the previously generated data files.
# Assumes that this script is executed after the DBT3 data gen script, and that the files are in
# the default locations.


PARTITIONS=`sh partitions.sh`
DBT3_DB=dbt3_db

echo "Creating Database"
createdb -uactian $DBT3_DB

echo "Creating tables in database"
sql -uactian $DBT3_DB <<EOF

create table customer (
 c_custkey      INTEGER         not null
,c_name         VARCHAR(25)     not null
,c_address      VARCHAR(40)     not null
,c_nationkey    INTEGER         not null
,c_phone        CHAR(15)        not null
,c_acctbal      DECIMAL(18,2)   not null
,c_mktsegment   CHAR(10)        not null
,c_comment      VARCHAR(117)    not null
)
with nopartition;


create table lineitem (
 l_orderkey             INTEGER         not null
,l_partkey              INTEGER         not null
,l_suppkey              INTEGER         not null
,l_linenumber           INTEGER         not null
,l_quantity             DECIMAL(18,2)   not null
,l_extendedprice        DECIMAL(18,2)   not null
,l_discount             DECIMAL(18,2)   not null
,l_tax                  DECIMAL(18,2)   not null
,l_returnflag           CHAR(1)         not null
,l_linestatus           CHAR(1)         not null
,l_shipDATE             DATE            not null
,l_commitDATE           DATE            not null
,l_receiptDATE          DATE            not null
,l_shipinstruct         CHAR(25)        not null
,l_shipmode             CHAR(10)        not null
,l_comment              VARCHAR(44)     not null
)
with partition = (hash on l_orderkey $PARTITIONS partitions);

create table nation (
 n_nationkey    INTEGER         not null
,n_name         CHAR(25)        not null
,n_regionkey    INTEGER         not null
,n_comment      VARCHAR(152)    not null
)
with nopartition;


create table orders (
 o_orderkey             INTEGER         not null
,o_custkey              INTEGER         not null
,o_orderstatus          CHAR(1)         not null
,o_totalprice           DECIMAL(18,2)   not null
,o_orderDATE            DATE            not null
,o_orderpriority        CHAR(15)        not null
,o_clerk                CHAR(15)        not null
,o_shippriority         INTEGER         not null
,o_comment              VARCHAR(79)     not null
)
with partition = (hash on o_orderkey $PARTITIONS partitions);


create table partsupp (
 ps_partkey     INTEGER         not null
,ps_suppkey     INTEGER         not null
,ps_availqty    INTEGER         not null
,ps_supplycost  DECIMAL(18,2)   not null
,ps_comment     VARCHAR(199)    not null
)
with partition = (hash on ps_partkey, ps_suppkey $PARTITIONS partitions);


create table part (
 p_partkey      INTEGER         not null
,p_name         VARCHAR(55)     not null
,p_mfgr         CHAR(25)        not null
,p_brand        CHAR(10)        not null
,p_type         VARCHAR(25)     not null
,p_size         INTEGER         not null
,p_container    CHAR(10)        not null
,p_retailprice  DECIMAL(18,2)   not null
,p_comment      VARCHAR(23)     not null
)
with nopartition;


create table region (
 r_regionkey    INTEGER         not null
,r_name         CHAR(25)        not null
,r_comment      VARCHAR(152)    not null
)
with nopartition;


create table supplier (
 s_suppkey      INTEGER         not null
,s_name         CHAR(25)        not null
,s_address      VARCHAR(40)     not null
,s_nationkey    INTEGER         not null
,s_phone        CHAR(15)        not null
,s_acctbal      DECIMAL(18,2)   not null
,s_comment      VARCHAR(101)    not null
)
with nopartition;


\p\g

EOF

# Once the tables have been created, then load them with the generated test data.
# Include -z flag to auto-generate statistics as the data is loaded.

echo "Loading base tables with generated data"
# No point in adding stats to the load process, since we are really running the queries
# against the second version of the tables, once the data has been sorted.

# Assumes all intermediate files are on the local filesystem, hence doesn't use the cluster
# option for vwload (since that requires files in HDFS to work with).

vwload -z -m -t customer -uactian $DBT3_DB /tmp/customer.tbl*
vwload -z -m -t lineitem -uactian $DBT3_DB /tmp/lineitem.tbl*
vwload -z -m -t nation -uactian $DBT3_DB /tmp/nation.tbl*
vwload -z -m -t orders -uactian $DBT3_DB /tmp/orders.tbl*
vwload -z -m -t partsupp -uactian $DBT3_DB /tmp/partsupp.tbl*
vwload -z -m -t part -uactian $DBT3_DB /tmp/part.tbl*
vwload -z -m -t region -uactian $DBT3_DB /tmp/region.tbl*
vwload -z -m -t supplier -uactian $DBT3_DB /tmp/supplier.tbl*

echo Now creating sorted version of this data, to improve performance.
echo Starting at `date`

sql $DBT3_DB<<EOF
alter table customer add primary key(c_custkey);
commit;

alter table lineitem add primary key(l_orderkey);
commit;

alter table nation add primary key(n_nationkey);
commit;

alter table orders add primary key(o_orderkey);
commit;

alter table partsupp add primary key(ps_partkey, ps_suppkey);
commit;

alter table part add primary key(p_partkey);
commit;

alter table region add primary key(r_regionkey);
commit;

alter table supplier add primary key(s_suppkey);
commit;

\p\g
EOF

echo Database and tables all created and data loaded at `date`.

# Following section commented out as we use the -z flag to vwload to gather stats
# at load time.

# Now gather statistics on the tables
# Just gather stats on all tables and columns by default.

# echo Now gathering statistics on the data distribution

# optimizedb $DBT3_DB
