#!/bin/bash

#before executing this script it is assumed that limtus tests
#are already compiled end the corresponding elf files are 
#in the $riscv-litmus-test-dir specified in the main Makefile


#remove all output logs
rm log/*

cva6 make clean
#save all tests names in a file
cva6 make find-litmus
#run all litmus tests in parallel (with 8 threads)
cva6 make -j8 run-litmus-tests batch-mode=1

#merge all logs in a unique text file
./ci/merge-tests.sh
