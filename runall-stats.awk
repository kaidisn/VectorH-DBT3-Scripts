#!/bin/awk
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

# This performs some simple statistical analysis of the results of a set of query tests executed by 
# the 'runall' script, which by default places all of its log files in /tmp.

# To execute, execute via: `awk -f runall-stats.awk /tmp/run*log`


BEGIN {
    min_query_time = 9999;
    max_query_time = 0;
    total_query_time = 0;
    query_cnt = 0;
}

/ rows in / {
    time = $4;
    if (time < min_query_time) min_query_time = time;
    if (time > max_query_time) max_query_time = time;
    total_query_time = total_query_time + time;
    query_times[query_cnt] = time;
    query_cnt++;
}

END {
    num_results = asort(query_times);
    median_val = int(num_results/2);
    print "Minimum query execution time was " min_query_time;
    print "Maximum query execution time was " max_query_time;
    print "Mean query execution time was " total_query_time / query_cnt;
    print "Median query execution time was " query_times[median_val];
    print "Total execution time for all queries was " total_query_time;

    # To give an idea of the spread of results, chunk them into 10 buckets and provide the range of each bucket
    bucket_size = int(num_results/10) + 1;
    i=1;
    bucket_count=1;
    do {
        if (i + bucket_size > num_results)
            bucket_size = num_results - i;

        print "Range of bucket ", bucket_count, " is ", query_times[i], " to ", query_times[i + bucket_size];
        i+=bucket_size;
        bucket_count++;
    }
    while (i < num_results);

    # Print out the total run time to a file for summary
    # Baseline runtime on bare-metal cluster is about 45 seconds for a 5-user test, so calculate this result relative to that.
    relative_result=(total_query_time/45)*100;
    printf "%d%", relative_result > "run_performance.out";
}