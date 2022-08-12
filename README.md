THE TPC SOFTWARE IS AVAILABLE WITHOUT CHARGE FROM TPC.

# TPCx-HS - Version 2

## Purpose

This repository takes the legacy TPCx-HS benchmarks and adds extended functionalities plus upgrade to more recent version of spark and schedulers.

## Courtesy of TPC https://www.tpc.org/tpcx-hs/

Note: TPCx-HS Version 1 and TPCx-HS Version 2 are NOT comparable

TPCx-HS is a Big Data System Benchmark

The Hadoop ecosystem is moving fast beyond batch processing with MapReduce. Introduced in 2016 TPCx-HS V2 is based on TPCx-HS V1 with support for Apache Spark - a popular platform for in-memory data processing that enables real-time analytics on Apache Hadoop. TPCx-HS V2 also supports MapReduce (MR2) and supports publications on traditional on premise deployments and clouds. More information about TPCx-HS v1 can be found at http://www.tpc.org/tpcx-hs/default5.asp?version=1. The TPCx-HS v2 benchmark can be used to assess a broad range of system topologies and implementation methodologies in a technically rigorous and directly comparable, in a vendor-neutral manner. 

The current TPCx-HS Version 2 specification can be found on the TPC Documentation Webpage https://www.tpc.org/tpc_documents_current_versions/current_specifications5.asp

## Usage

- compile the source: TPCx-HS-SRC/README.md 
- make the jars (at least the spark jar) available using an hdfs, http server or S3/minio.
- configure your running parameters in TPCx-HS-Runtime-Suite/Benchmark_Parameters.sh
- run : `cd TPCx-HS-Runtime-Suite && ./TPCx-HS-master.sh -s -q mesos -g -1`

## Releases

- 2.1.0 : (not a TPC release) add support for spark on mesos scheduler and spark v2
- 2.0.3 : last release from TPC. Only support spark 1.6 using yarn scheduler.
