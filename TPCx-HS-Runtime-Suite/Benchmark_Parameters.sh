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

unalias exportz 2>/dev/null
exportz()
{
    # avoid to export KV if it was already set before
    key=`echo $1 | awk -F '=' '{print $1}'`
    valOld=$(echo ${!key}) # bash only, not working in zsh
    vals=$(echo $1 | awk -F '=' '{print $2}')
    if [[ -z $valOld ]]; then
        export $key=$vals
    fi
}

#-----------------------------------
# Common Parameters
#-----------------------------------
# export HADOOP_USER=root # to name the directory /user/"$HADOOP_USER"
# export HDFS_USER=root # to run hadoop admin command
exportz HADOOP_USER=$USER # to name the directory /user/"$HADOOP_USER"
export HDFS_USER=$USER # to run hadoop admin command
exportz HDFS_BENCHMARK_DIR="TPCx-HS-benchmark"
export SLEEP_BETWEEN_RUNS=1
exportz NBLOOP=2
#-----------------------------------
# Jar path
#-----------------------------------
export MR_HSSORT_JAR="TPCx-HS-master_MR2.jar"
exportz SPARK_HSSORT_JAR="local:///opt/spark/examples/jars/TPCx-HS-master_Spark_2.12-3.3.0_2.2.0.jar"
#exportz SPARK_HSSORT_JAR="s3a://spark-deps-dev/TPCx-HS-master_Spark_2.12-3.3.0_2.3.0.jar"
#exportz SPARK_HSSORT_JAR="s3a://bu002i002901/applications/TPCx-HS-master_Spark_2.12-3.3.0_2.2.0-beta.jar"
#exportz SPARK_HSSORT_JAR="s3a://jars/TPCx-HS-master_Spark_2.12-3.3.0_2.2.0-beta.jar"

#-----------------------------------
# MapReduce Parameters
#-----------------------------------
export NUM_MAPS=768
export NUM_REDUCERS=768


#-----------------------------------
# Spark Parameters
#-----------------------------------
# spark.default.parallelism should be set to nb_executors x nb_cores
#export SPARK_DEFAULT_PARALLELISM=1000 prefer using SPARK_TARGET_PARTITION_DISK_MB + heuristic depending on hssize
exportz SPARK_TARGET_PARTITION_DISK_MB=100

exportz SPARK_DRIVER_MEMORY=1g
exportz SPARK_DRIVER_CORES=1
exportz SPARK_EXECUTOR_MEMORY=32g
exportz SPARK_EXECUTOR_CORES=10
exportz SPARK_EXECUTOR_INSTANCES=6
# HSgen only
exportz hack_hsgen_only=0
if [[ "${hack_hsgen_only}" == "1" ]]; then
    echo "hack_hsgen_only = ${hack_hsgen_only}"
    export SPARK_EXECUTOR_MEMORY=8g
    #export SPARK_DEFAULT_PARALLELISM=$((${SPARK_EXECUTOR_CORES} * ${SPARK_EXECUTOR_INSTANCES}))
fi
export SPARK_CORES_MAX=$((${SPARK_EXECUTOR_CORES} * ${SPARK_EXECUTOR_INSTANCES})) # only for Dcos


# DEPLOY_MODE one of 'cluster' or 'client'. Should always be cluster for k8s scheduler
export SPARK_DEPLOY_MODE="cluster"

export SPARK_SCHEDULER="k8s"

export HADOOP_HOME=~/hadoop
if [[ ! -e ${HADOOP_HOME} ]]; then
    export HADOOP_HOME=/opt/hadoop
fi
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export PATH=${PATH}:${HADOOP_HOME}/bin

export SPARK_HOME=~/spark
if [[ ! -e ${SPARK_HOME} ]]; then
    export SPARK_HOME=/opt/spark
fi
if [[ ! -e ${SPARK_HOME} ]]; then
    export SPARK_HOME=/usr/local/spark
fi
export PATH=$PATH:${SPARK_HOME}/bin

export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")

# Master URL for the cluster. spark://host:port, mesos://host:port, yarn, or local
#export SPARK_MASTER_URL="mesos://leader.mesos:5050"
#export SPARK_MASTER_URL="spark://adm-tst-vm-1.local:7077"
export SPARK_MASTER_URL="k8s://https://192.168.122.61:6443"
# URIS to hdfs-site.xml,core-site.xml
# export SPARK_MESOS_URIS="http://hdfs-5.novalocal/hdfs-config/hdfs-site.xml,http://hdfs-5.novalocal/hdfs-config/core-site.xml"

##############################################################################################
export SPARK_KUBE_NS=ns-spark
export SPARK_KUBE_SA=sa-spark
#export SPARK_KUBE_IMAGE_PULLSECRETS=
##############################################################################################

export SPARK_KUBE_IMAGE=pepitedata/spark-hadoop:latest

#-----------------------------------
# Storage backend Parameters
#-----------------------------------
# Only for spark with S3 (minio) storage backend instead of HDFS
export s3host=10.233.13.193 # clusterIP
#export s3host=my-minio.default.svc.cluster.local
export s3port=9000
export s3address=$s3host:$s3port
# bucket name
export s3bucket=mybucket
export s3ssl=false
export s3ep=http://$s3address
export AWS_ACCESS_KEY_ID=g0VU8bPKlNTqP1Ol
export AWS_SECRET_ACCESS_KEY=xLkU5jWq7Ptg8kSqEc4B6HwytdVt4YCn

# Configure Storage backend
# HADOOP_DEFAULTFS must be resolved from the terminal running the TPCx script
export HADOOP_DEFAULTFS=""
# SPARK_DEFAULTFS must be resolved from inside the spark containers/process
export SPARK_DEFAULTFS=""
# with kubernetes different HADOOP url are used whether the client is external or internal to the kubernetes cluster
# exemple with hdfs
#export HADOOP_DEFAULTFS=hdfs://u20-3:32664/
#export SPARK_DEFAULTFS=hdfs://hdfs-service.default.svc.cluster.local:9000/
# exemple with s3a
#export HADOOP_DEFAULTFS=s3a://$s3address/$s3bucket
export HADOOP_DEFAULTFS=$s3tenant:$s3bucket
export SPARK_DEFAULTFS=s3a://$s3address
