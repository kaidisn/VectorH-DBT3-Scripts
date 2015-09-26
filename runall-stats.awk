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
    query_cnt++;
}

END {
    print "min_query_time = " min_query_time;
    print "max_query_time = " max_query_time;
    print "average_query_time = " total_query_time / query_cnt;
    print "total_query_time =" total_query_time;
}