Collection of scripts to simplify execution of DBT3 benchmark testing with Actian Vector-H.
Initial release consists of a script to calculate the number of partitions that a large table 
should contain, based on the formula: 

 *#CPUs * #Cores-per-CPU * #Data-nodes-in-the-cluster*

The result is echo'd to the command line.
