#!/bin/bash

# CPU Benchmark
sysbench --test=cpu --cpu-max-prime=150000 run
sysbench --test=cpu --cpu-max-prime=15000 run --num-threads=4

#FILE IO Benchmark
sysbench --test=fileio --file-total-size=150G --file-test-mode=seqwr run
sysbench --test=fileio --file-total-size=150G cleanup

#MEMORY Benchmark
sysbench --test=memory --memory-block-size=1M --memory-total-size=8G run
sysbench --test=fileio --file-total-size=150G cleanup
