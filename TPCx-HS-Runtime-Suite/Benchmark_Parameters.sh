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
# export HADOOP_USER=root # to name the directory /user/"$HADOOP_USER"
# export HDFS_USER=root # to run hadoop admin command
export HADOOP_USER=$USER # to name the directory /user/"$HADOOP_USER"
export HDFS_USER=$USER # to run hadoop admin command
export HDFS_BENCHMARK_DIR="TPCx-HS-benchmark"
export SLEEP_BETWEEN_RUNS=20
#-----------------------------------
# Jar path
#-----------------------------------
export MR_HSSORT_JAR="TPCx-HS-master_MR2.jar"
#export SPARK_HSSORT_JAR="hdfs:///jars/TPCx-HS-master_Spark.jar"
export SPARK_HSSORT_JAR="http://192.168.1.3:18000/TPCx-HS-master_Spark_2.12-3.3.0_2.2.0.jar"

#-----------------------------------
# MapReduce Parameters
#-----------------------------------
export NUM_MAPS=768
export NUM_REDUCERS=768


#-----------------------------------
# Spark Parameters
#-----------------------------------
export SPARK_DRIVER_MEMORY=4g
export SPARK_EXECUTOR_MEMORY=20g
export SPARK_EXECUTOR_CORES=5
export SPARK_EXECUTOR_INSTANCES=16
# spark.default.parallelism should be set to nb_executors x nb_cores
export SPARK_DEFAULT_PARALLELISM=10000
export SPARK_CORES_MAX=80


# DEPLOY_MODE one of 'cluster' or 'client'. Should always be cluster for k8s scheduler
export SPARK_DEPLOY_MODE="cluster"

export SPARK_SCHEDULER="Yarn"

# Master URL for the cluster. spark://host:port, mesos://host:port, yarn, or local
#export SPARK_MASTER_URL="mesos://leader.mesos:5050"
#export SPARK_MASTER_URL="spark://adm-tst-vm-1.local:7077"
export SPARK_MASTER_URL="k8s://https://192.168.122.61:6443"
# URIS to hdfs-site.xml,core-site.xml
# export SPARK_MESOS_URIS="http://hdfs-5.novalocal/hdfs-config/hdfs-site.xml,http://hdfs-5.novalocal/hdfs-config/core-site.xml"

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

# Only for spark on Kubernetes (scheduler=k8s)
export SPARK_KUBE_NS=ns-spark
export SPARK_KUBE_SA=sa-spark
#export SPARK_KUBE_IMAGE=gcr.io/datamechanics/spark:platform-3.3-latest
export SPARK_KUBE_IMAGE=pepitedata/spark-hadoop:3.3.0-3.3.3

# Only for spark with S3 (minio) storage backend instead of HDFS
export s3host=10.233.43.160
export s3port=9000
export miniourl=$s3host:$s3port
# bucket name
export s3bucket=mybucket
# name of the tenant as configured in mc CLI (~/.mc/config.json)
export s3tenant=local
export s3ssl=false
export s3ep=http://$miniourl
export AWS_ACCESS_KEY_ID=X0Cm57RiQ0YQsIco
export AWS_SECRET_ACCESS_KEY=Vo25o0iY8TCoPF0qvn17yCC3xQ6F20Gg

# Configure Storage backend
# HADOOP_DEFAULTFS must be resolved from the terminal running the TPCx script
export HADOOP_DEFAULTFS=""
# SPARK_DEFAULTFS must be resolved from inside the spark containers/process
export SPARK_DEFAULTFS=""
# with kubernetes different HADOOP url are used whether the client is external or internal to the kubernetes cluster
# exemple with hdfs
export HADOOP_DEFAULTFS=hdfs://u20-3:32664/
export SPARK_DEFAULTFS=hdfs://hdfs-service.default.svc.cluster.local:9000/
# exemple with s3a
export HADOOP_DEFAULTFS=$s3tenant/$s3bucket
export SPARK_DEFAULTFS=s3a://$miniourl
