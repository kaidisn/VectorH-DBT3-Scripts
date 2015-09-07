#!/bin/bash
# Script to create a DBT3 test database then create the tables, with reasonable default partitions.
# Then we load the data from the previously generated data files.
# Assumes that this script is executed after the DBT3 data gen script, and that the files are in
# the default locations.


PARTITIONS=`~/partitions.sh`
DBT3_DB=dbt3_db

createdb -uactian $DBT3_DB

sql -uactian $DBT3_DB <<EOF
create table customer2 as
select *
  from
 customer
order by
c_custkey;
alter table customer2 add primary key(c_custkey);

create table lineitem2 as
select *
  from
 lineitem
order by
 l_orderkey
with partition = (hash on l_orderkey $PARTITIONS partitions);

create table nation2 as
select *
  from
 nation
order by
n_nationkey;
alter table nation2 add primary key(n_nationkey);

create table orders2 as
select *
  from
 orders
order by
 o_orderdate
with partition = (hash on o_orderkey $PARTITIONS partitions);
alter table orders2 add primary key(o_orderkey);

create table partsupp2 as
select *
  from
 partsupp
order by
 ps_partkey
with partition = (hash on ps_partkey, ps_suppkey $PARTITIONS partitions);
alter table partsupp2 add primary key(ps_partkey, ps_suppkey);

create table part2 as
select *
  from
 part
order by
 p_partkey;
alter table part2 add primary key(p_partkey);

create table region2 as
select *
  from
 region
order by
 r_regionkey;
alter table region2 add primary key(r_regionkey);

create table supplier2 as
select *
  from
 supplier
order by
s_suppkey;
alter table supplier2 add primary key(s_suppkey);

\p\g

EOF

# Once the tables have been created, then load them with the generated test data.
# Include -z flag to auto-generate statistics as the data is loaded.

vwload -z –m –t customer –f “|” –uactian $DBT3_DB /tmp/customer.tbl
vwload -z –m –t lineitem –f “|” –uactian $DBT3_DB /tmp/lineitem.tbl
vwload -z –m –t nation –f “|” –uactian $DBT3_DB /tmp/nation.tbl
vwload -z –m –t orders –f “|” –uactian $DBT3_DB /tmp/orders.tbl
vwload -z –m –t partsupp –f “|” –uactian $DBT3_DB /tmp/partsupp.tbl
vwload -z –m –t part –f “|” –uactian $DBT3_DB /tmp/part.tbl
vwload -z –m –t region –f “|” –uactian $DBT3_DB /tmp/region.tbl
vwload -z –m –t supplier –f “|” –uactian $DBT3_DB /tmp/supplier.tbl

