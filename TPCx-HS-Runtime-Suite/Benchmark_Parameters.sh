#!/bin/bash
#
# Legal Notice
#
# This document and associated source code (the "Work") is a part of a
# benchmark specification maintained by the TPC.
#
# The TPC reserves all right, title, and interest to the Work as provided
# under U.S. and international laws, including without limitation all patent
# and trademark rights therein.
#
# No Warranty
#
# 1.1 TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE INFORMATION
#     CONTAINED HEREIN IS PROVIDED "AS IS" AND WITH ALL FAULTS, AND THE
#     AUTHORS AND DEVELOPERS OF THE WORK HEREBY DISCLAIM ALL OTHER
#     WARRANTIES AND CONDITIONS, EITHER EXPRESS, IMPLIED OR STATUTORY,
#     INCLUDING, BUT NOT LIMITED TO, ANY (IF ANY) IMPLIED WARRANTIES,
#     DUTIES OR CONDITIONS OF MERCHANTABILITY, OF FITNESS FOR A PARTICULAR
#     PURPOSE, OF ACCURACY OR COMPLETENESS OF RESPONSES, OF RESULTS, OF
#     WORKMANLIKE EFFORT, OF LACK OF VIRUSES, AND OF LACK OF NEGLIGENCE.
#     ALSO, THERE IS NO WARRANTY OR CONDITION OF TITLE, QUIET ENJOYMENT,
#     QUIET POSSESSION, CORRESPONDENCE TO DESCRIPTION OR NON-INFRINGEMENT
#     WITH REGARD TO THE WORK.
# 1.2 IN NO EVENT WILL ANY AUTHOR OR DEVELOPER OF THE WORK BE LIABLE TO
#     ANY OTHER PARTY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO THE
#     COST OF PROCURING SUBSTITUTE GOODS OR SERVICES, LOST PROFITS, LOSS
#     OF USE, LOSS OF DATA, OR ANY INCIDENTAL, CONSEQUENTIAL, DIRECT,
#     INDIRECT, OR SPECIAL DAMAGES WHETHER UNDER CONTRACT, TORT, WARRANTY,
#     OR OTHERWISE, ARISING IN ANY WAY OUT OF THIS OR ANY OTHER AGREEMENT
#     RELATING TO THE WORK, WHETHER OR NOT SUCH AUTHOR OR DEVELOPER HAD
#     ADVANCE NOTICE OF THE POSSIBILITY OF SUCH DAMAGES.
#

#-----------------------------------
# Common Parameters
#-----------------------------------
HADOOP_USER=root # to name the directory /user/"$HADOOP_USER"
HDFS_USER=root # to run hadoop admin command
HDFS_BENCHMARK_DIR="TPCx-HS-benchmark"
SLEEP_BETWEEN_RUNS=60

#-----------------------------------
# MapReduce Parameters
#-----------------------------------
NUM_MAPS=768
NUM_REDUCERS=768


#-----------------------------------
# Spark Parameters
#-----------------------------------
SPARK_DRIVER_MEMORY=4g
SPARK_EXECUTOR_MEMORY=20g
SPARK_EXECUTOR_CORES=5
SPARK_EXECUTOR_INSTANCES=16
# spark.default.parallelism should be set to nb_executors x nb_cores
SPARK_DEFAULT_PARALLELISM=10000
SPARK_CORES_MAX=80


# DEPLOY_MODE one of 'cluster' or 'client'
SPARK_DEPLOY_MODE="cluster"

SPARK_SCHEDULER="Yarn"

# Master URL for the cluster. spark://host:port, mesos://host:port, yarn, or local
#SPARK_MASTER_URL="mesos://leader.mesos:5050"
SPARK_MASTER_URL="spark://adm-tst-vm-1.local:7077"
# URIS to hdfs-site.xml,core-site.xml
# SPARK_MESOS_URIS="http://hdfs-5.novalocal/hdfs-config/hdfs-site.xml,http://hdfs-5.novalocal/hdfs-config/core-site.xml"

export HADOOP_HOME=/usr/local/hadoop
if [[ ! -e ${HADOOP_HOME} ]]; then
    export HADOOP_HOME=/opt/hadoop
fi
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export PATH=${PATH}:${HADOOP_HOME}/bin

export SPARK_HOME=/usr/local/spark
if [[ ! -e ${SPARK_HOME} ]]; then
    export SPARK_HOME=/opt/spark
fi
export PATH=$PATH:${SPARK_HOME}/bin

export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")

# Only for spark on mesos (not useful for spark on dcos)
export LIBMESOS_BUNDLE_DOWNLOAD_URL="https://downloads.mesosphere.io/libmesos-bundle/libmesos-bundle-1.12.0.tar.gz"
export BOOTSTRAP_DOWNLOAD_URL="https://downloads.mesosphere.com/dcos-commons/artifacts/0.55.2/bootstrap.zip"
export MESOSPHERE_HOME="/opt/mesosphere"
export BOOTSTRAP_BINARY="${MESOSPHERE_HOME}/bootstrap.zip"
export BOOTSTRAP=${MESOSPHERE_HOME}/bootstrap
export MESOS_NATIVE_JAVA_LIBRARY=${MESOSPHERE_HOME}/lib/libmesos.so
export LD_LIBRARY_PATH=${MESOSPHERE_HOME}/lib/

# Only for spark on DC/OS
# Spark on DC/OS uses Mesos scheduler, but job submission must be handled through dcos cli 
# otherwise the driver will be running on localhost
# Warning on DCOS the Spark jar must be a fatjar !
export DCOS=/usr/local/bin/dcos
#export DCOS=/opt/dcos-cli/dcos
export SPARK_DCOS_SERVICE_NAME="spark-1-6"
