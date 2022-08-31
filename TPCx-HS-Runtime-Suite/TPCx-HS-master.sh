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

#set -x
shopt -s expand_aliases
source ./Benchmark_Parameters.sh

VERSION=`cat ./VERSION.txt`

#script assumes clush or pdsh
#unalias psh
if (type clush > /dev/null); then
    alias psh=clush
    alias dshbak=clubak
    CLUSTER_SHELL=1
elif (type pdsh > /dev/null); then
    CLUSTER_SHELL=1
    alias psh=pdsh
fi
parg="-a"

# Setting Color codes
green='\e[0;32m'
red='\e[0;31m'
NC='\e[0m' # No Color

sep='==================================='

usage()
{
    cat << EOF
TPCx-HS version $VERSION 
usage: $0 options

This script runs the TPCx-HS (Hadoop Sort) BigData benchmark suite

OPTIONS:
   -h  Help
   -m  Use the MapReduce framework
   -s  Use the Spark framework
   -q  Specify the ressource scheduler for Spark : Yarn (Default) or Mesos or Dcos or k8s
   -g  <TPCx-HS Scale Factor option from below>
       -1  Run TPCx-HS for 1GB (For test purpose only, not a valid Scale Factor)
       0   Run TPCx-HS for 30GB (For test purpose only, not a valid Scale Factor)
       1   Run TPCx-HS for 100GB (For test purpose only, not a valid Scale Factor)
       2   Run TPCx-HS for 1TB
       3   Run TPCx-HS for 3TB
       4   Run TPCx-HS for 10TB
       5   Run TPCx-HS for 30TB
       6   Run TPCx-HS for 100TB
       7   Run TPCx-HS for 300TB
       8   Run TPCx-HS for 1000TB
       9   Run TPCx-HS for 3000TB
       10  Run TPCx-HS for 10000TB

   Example: $0 -m -g 0 -q k8s -b s3a

EOF
}

while getopts "hmsb:g:q:" OPTION; do
    case ${OPTION} in
        h) usage
           exit 1
           ;;
        m) FRAMEWORK="MapReduce"
           HSSORT_JAR="$MR_HSSORT_JAR"
           ;;
        s) FRAMEWORK="Spark"
           HSSORT_JAR="$SPARK_HSSORT_JAR"
           ;;
        b) STORAGE_BACKEND=$OPTARG
           case $v in
               hdfs) STORAGE_BACKEND=hdfs
                     ;;
               s3a) STORAGE_BACKEND=s3a
                    ;;
               ?) STORAGE_BACKEND=hdfs
               ;;
           esac
           ;;
        q) SPARK_SCHEDULER=$OPTARG
           ;;
        g)  sze=$OPTARG
            case $sze in
                -1) hssize="10000000"
                    prefix="1GB"
                    ;;
                0) hssize="300000000"
                   prefix="30GB"
                   ;;
                1) hssize="1000000000"
                   prefix="100GB"
                   ;;
                2) hssize="10000000000"
                   prefix="1TB"
                   ;;
                3) hssize="30000000000"
                   prefix="3TB"
                   ;;        
                4) hssize="100000000000"
                   prefix="10TB"
                   ;;        
                5) hssize="300000000000"
                   prefix="30TB"
                   ;;        
                6) hssize="1000000000000"
                   prefix="100TB"
                   ;;        
                7) hssize="3000000000000"
                   prefix="300TB"
                   ;;        
                8) hssize="10000000000000"
                   prefix="1000TB"
                   ;;        
                9) hssize="30000000000000"
                   prefix="3000TB"
                   ;;        
                10) hssize="100000000000000"
                    prefix="10000TB"
                    ;;
                ?) hssize="1000000000"
                prefix="100GB"
                ;;
            esac
            ;;
        ?)  echo -e "${red}Please choose a valid option${NC}"
        usage
        exit 2
        ;;
    esac
done

export FRAMEWORK=$FRAMEWORK
export HSSORT_JAR=${HSSORT_JAR}
export SPARK_SCHEDULER=${SPARK_SCHEDULER}
export STORAGE_BACKEND=${STORAGE_BACKEND}


if [ -z "$FRAMEWORK" ]; then
    echo
    echo "Please specify the framework to use (-m or -s or -sd)"
    echo
    usage
    exit 2
elif [ -z "$hssize" ]; then
    echo
    echo "Please specify the scale factor to use (-g)"
    echo
    usage
    exit 2
fi

if [[ -z $(which bc 2>/dev/null) ]] ; then
    echo
    echo "Please install bc"
    echo
    exit 3
fi

if [[ "${STORAGE_BACKEND}" == "s3a" && "$FRAMEWORK" != "Spark" ]] ; then
    echo
    echo "Please use Spark framework with s3a storage backend"
    echo
    exit 4
fi

logfile=./TPCx-HS-result-"$prefix".log

if [ -f ${logfile} ]; then
    mv ${logfile} ${logfile}.`date +%Y%m%d%H%M%S`
fi

echo "" | tee -a ${logfile}
echo -e "${green}Running $FRAMEWORK $prefix test${NC}" | tee -a ${logfile}
if [ "$FRAMEWORK" = "Spark" ]; then
    echo -e "${green}Using ${SPARK_SCHEDULER} for scheduling${NC}" | tee -a ${logfile}
fi
echo -e "${green}HSsize is $hssize${NC}" | tee -a ${logfile}
echo -e "${green}All Output will be logged to file ./TPCx-HS-result-$prefix.log${NC}" | tee -a ${logfile}
echo "" | tee -a ${logfile}

## CLUSTER VALIDATE SUITE ##


if [[ ${CLUSTER_SHELL} -eq 1 ]] ; then
    echo -e "${green}$sep${NC}" | tee -a ${logfile}
    echo -e "${green} Running Cluster Validation Suite${NC}" | tee -a ${logfile}
    echo -e "${green}$sep${NC}" | tee -a ${logfile}
    echo "" | tee -a ${logfile}
    echo "" | tee -a ${logfile}

    source ./BigData_cluster_validate_suite.sh | tee -a ${logfile}

    echo "" | tee -a ${logfile}
    echo -e "${green} End of Cluster Validation Suite${NC}" | tee -a ${logfile}
    echo "" | tee -a ${logfile}
    echo "" | tee -a ${logfile}
else
    echo -e "${red}CLUSH NOT INSTALLED for cluster audit report${NC}" | tee -a ${logfile}
    echo -e "${red}To install clush follow USER_GUIDE.txt${NC}" | tee -a ${logfile}
fi

## BIGDATA BENCHMARK SUITE ##
# exit on error

# Note for 1TB (1000000000000), input for HSgen => 10000000000 (so many 100 byte words)
if [[ "${STORAGE_BACKEND}" == "hdfs" ]]; then
    if [[ ! -z ${HADOOP_DEFAULTFS} ]]; then
        export hdfsopt="-fs ${HADOOP_DEFAULTFS}"
    fi

    if [[ "$USER" != "$HDFS_USER" ]]; then
        sudo -u $HDFS_USER ${HADOOP_HOME}/bin/hadoop fs ${hdfsopt} -mkdir /user
        sudo -u $HDFS_USER ${HADOOP_HOME}/bin/hadoop fs -mkdir /user/"$HADOOP_USER"
        sudo -u $HDFS_USER ${HADOOP_HOME}/bin/hadoop fs -chown "$HADOOP_USER" /user/"$HADOOP_USER"
    else
        ${HADOOP_HOME}/bin/hadoop fs ${hdfsopt} -mkdir /user
        ${HADOOP_HOME}/bin/hadoop fs ${hdfsopt} -mkdir /user/"$HADOOP_USER"
        ${HADOOP_HOME}/bin/hadoop fs ${hdfsopt} -chown "$HADOOP_USER" /user/"$HADOOP_USER"
    fi

    ${HADOOP_HOME}/bin/hadoop fs ${hdfsopt} -ls "${HDFS_BENCHMARK_DIR}"
    if [ $? != 0 ] ;then
        ${HADOOP_HOME}/bin/hadoop fs ${hdfsopt} -mkdir "${HDFS_BENCHMARK_DIR}"
    fi
fi

# Loop on the end to end test to ensure results are reproducible and stable
# official benchmark : only 2 iterations
for i in {1..2};
do
    set +e
    benchmark_result=1

    echo -e "${green}$sep${NC}" | tee -a ${logfile}
    echo -e "${green}Deleting Previous Data - Start - `date`${NC}" | tee -a ${logfile}
    if [[ "${STORAGE_BACKEND}" == "hdfs" ]]; then
        ${HADOOP_HOME}/bin/hadoop fs ${hdfsopt} -rm -r -skipTrash /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/*
        if [[ "$USER" != "$HDFS_USER" ]]; then
            sudo -u $HDFS_USER ${HADOOP_HOME}/bin/hadoop fs ${hdfsopt} -expunge
        else
            ${HADOOP_HOME}/bin/hadoop fs ${hdfsopt} -expunge
        fi
    else
        mc rm --recursive --force ${HADOOP_DEFAULTFS}/user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"
    fi
    echo "sleep $SLEEP_BETWEEN_RUNS"
    sleep $SLEEP_BETWEEN_RUNS

    set -e
    echo -e "${green}Deleting Previous Data - End - `date`${NC}" | tee -a ${logfile}
    echo -e "${green}$sep${NC}" | tee -a ${logfile}
    echo "" | tee -a ${logfile}
    echo "" | tee -a ${logfile}

    start=`date +%s`
    echo -e "${green}$sep${NC}" | tee -a ${logfile}
    echo -e "${green} Running BigData TPCx-HS Benchmark Suite ($FRAMEWORK) - Run $i - Epoch $start ${NC}" | tee -a ${logfile}
    echo -e "${green} TPCx-HS Version $VERSION ${NC}" | tee -a ${logfile}
    echo -e "${green}$sep${NC}" | tee -a ${logfile}
    echo "" | tee -a ${logfile}
    echo -e "${green}Starting HSGen Run $i (output being written to ./logs/HSgen-time-run$i.txt)${NC}" | tee -a ${logfile}
    echo "" | tee -a ${logfile}


    mkdir -p ./logs
    if [ "$FRAMEWORK" = "MapReduce" ]; then
        echo ${HADOOP_HOME}/bin/hadoop jar $HSSORT_JAR HSGen -Dmapreduce.job.maps=$NUM_MAPS -Dmapreduce.job.reduces=$NUM_REDUCERS -Dmapred.map.tasks=$NUM_MAPS -Dmapred.reduce.tasks=$NUM_REDUCERS $hssize /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-input
        (time ${HADOOP_HOME}/bin/hadoop jar $HSSORT_JAR HSGen -Dmapreduce.job.maps=$NUM_MAPS -Dmapreduce.job.reduces=$NUM_REDUCERS -Dmapred.map.tasks=$NUM_MAPS -Dmapred.reduce.tasks=$NUM_REDUCERS $hssize /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-input) 2> >(tee ./logs/HSgen-time-run$i.txt)
        result=$?
    elif [ "$FRAMEWORK" = "Spark" ]; then
        if [[ -z ${SPARK_DEFAULT_PARALLELISM} && ! -z ${SPARK_TARGET_PARTITION_DISK_MB} ]] ; then
            export SPARK_DEFAULT_PARALLELISM=`echo "$hssize *100/( ${SPARK_TARGET_PARTITION_DISK_MB} *1024*1024 )" | bc`
            if [[ ! -z ${SPARK_EXECUTOR_INSTANCES} ]]; then
                export SPARK_DEFAULT_PARALLELISM=`echo "${SPARK_DEFAULT_PARALLELISM} / ${SPARK_EXECUTOR_INSTANCES}" | bc`
                export SPARK_DEFAULT_PARALLELISM=`echo "${SPARK_DEFAULT_PARALLELISM} * ${SPARK_EXECUTOR_INSTANCES}" | bc`
            fi
        fi
        if [[ ! -z ${SPARK_EXECUTOR_INSTANCES} && ${SPARK_DEFAULT_PARALLELISM} -lt ${SPARK_EXECUTOR_INSTANCES} ]]; then
            export SPARK_DEFAULT_PARALLELISM=${SPARK_EXECUTOR_INSTANCES}
        fi
        echo "SPARK_DEFAULT_PARALLELISM=${SPARK_DEFAULT_PARALLELISM}"
        export sparkopt="--conf spark.driver.memory=${SPARK_DRIVER_MEMORY} --conf spark.executor.memory=${SPARK_EXECUTOR_MEMORY} --conf spark.executor.cores=${SPARK_EXECUTOR_CORES} --conf spark.executor.instances=${SPARK_EXECUTOR_INSTANCES} --conf spark.default.parallelism=${SPARK_DEFAULT_PARALLELISM}"
        export spark_fs_prefix=""
        if [[ ! -z ${SPARK_DEFAULTFS} ]]; then
            sparkopt="$sparkopt --conf spark.hadoop.fs.defaultFS=${SPARK_DEFAULTFS}"
        fi
        if [ "${SPARK_SCHEDULER}" = "Dcos" ]; then
            sparkopt="$sparkopt --conf spark.cores.max=${SPARK_CORES_MAX}" 
            echo ${DCOS} spark --name="${SPARK_DCOS_SERVICE_NAME}" run --submit-args="--class HSGen ${sparkopt} ${HSSORT_JAR} ${hssize} /user/${HADOOP_USER}/${HDFS_BENCHMARK_DIR}/HSsort-input/"
            jobid=`${DCOS} spark --name="${SPARK_DCOS_SERVICE_NAME}" run --submit-args="--class HSGen ${sparkopt} ${HSSORT_JAR} ${hssize} /user/${HADOOP_USER}/${HDFS_BENCHMARK_DIR}/HSsort-input/" | grep "Submission id:" | awk '{print $NF}'`
            result=$?
            if [[ ! -z {jobid} ]]; then 
                (time while [[ `${DCOS} spark --name="${SPARK_DCOS_SERVICE_NAME}" status ${jobid} | grep '"driverState"' | grep -c '"FINISHED"'` -eq 0 ]]; do printf '.'; sleep 5; done) | (tee ./logs/HSgen-time-run${i}.txt)
            fi
        else
            if [ "${SPARK_SCHEDULER}" = "k8s" ]; then
                sparkopt="$sparkopt --master ${SPARK_MASTER_URL} --conf spark.kubernetes.container.image=${SPARK_KUBE_IMAGE} --deploy-mode cluster"
                if [[ ! -z ${SPARK_KUBE_NS} ]]; then
                    sparkopt="$sparkopt --conf spark.kubernetes.namespace=${SPARK_KUBE_NS}"
                fi
                if [[ ! -z ${SPARK_KUBE_SA} ]]; then
                    sparkopt="$sparkopt --conf spark.kubernetes.authenticate.driver.serviceAccountName=${SPARK_KUBE_SA}"
                fi
                if [[ ! -z ${SPARK_KUBE_IMAGE_PULLSECRETS} ]]; then
                    sparkopt="$sparkopt --conf spark.kubernetes.container.image.pullSecrets=${SPARK_KUBE_IMAGE_PULLSECRETS}"
                fi
                if [[ "${STORAGE_BACKEND}" == "s3a" ]]; then
                    sparkopt="$sparkopt --conf spark.hadoop.fs.defaultFS=$SPARK_DEFAULTFS --conf spark.hadoop.fs.s3a.endpoint=$s3ep --conf spark.hadoop.fs.s3a.access.key=$AWS_ACCESS_KEY_ID --conf spark.hadoop.fs.s3a.secret.key=$AWS_SECRET_ACCESS_KEY --conf spark.hadoop.fs.s3a.connection.ssl.enabled=$s3ssl --conf spark.hadoop.fs.s3a.path.style.access=true"
                    sparkopt=$sparkopt' --conf "spark.driver.extraJavaOptions=-Dcom.amazonaws.services.s3.enableV4=true" --conf "spark.executor.extraJavaOptions=-Dcom.amazonaws.services.s3.enableV4=true"'
                    spark_fs_prefix=s3a://$s3bucket
                fi
            else
                sparkopt="$sparkopt --master ${SPARK_MASTER_URL} --deploy-mode ${SPARK_DEPLOY_MODE}"
            fi
            echo ${SPARK_HOME}/bin/spark-submit --class HSGen ${sparkopt} ${HSSORT_JAR} ${hssize} ${spark_fs_prefix}/user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-input/
            (time ${SPARK_HOME}/bin/spark-submit --class HSGen ${sparkopt} ${HSSORT_JAR} ${hssize} ${spark_fs_prefix}/user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-input/ ) 2>&1 | (tee ./logs/HSgen-time-run${i}.txt)
            result=$?
        fi
    fi

    cat ./logs/HSgen-time-run${i}.txt >> ${logfile}

    if [[ $result -ne 0 ]]
    then
        echo -e "${red}======== HSgen Result FAILURE ========${NC}" | tee -a ${logfile}
        benchmark_result=0
    else
        echo "" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
        echo -e "${green}======== HSgen Result SUCCESS ========${NC}" | tee -a ${logfile}
        echo -e "${green}======== Time taken by HSGen = `grep real ./logs/HSgen-time-run$i.txt | awk '{print $2}'`====${NC}" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
    fi

    echo "" | tee -a ${logfile}
    echo -e "${green}Listing HSGen output ${NC}" | tee -a ${logfile}
    echo "" | tee -a ${logfile}
    ./HSDataCheck.sh ${HADOOP_DEFAULTFS}/user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-input >> ${logfile}
    if [[ $? -ne 0 ]]; then echo "ERROR !"; exit 9; fi
    echo "" | tee -a ${logfile}

    echo "" | tee -a ${logfile}
    echo "" | tee -a ${logfile}
    echo -e "${green}Starting HSSort Run $i (output being written to ./logs/HSsort-time-run$i.txt)${NC}" | tee -a ${logfile}
    echo "" | tee -a ${logfile}

    if [ "$FRAMEWORK" = "MapReduce" ]; then
        echo ${HADOOP_HOME}/bin/hadoop jar $HSSORT_JAR HSSort -Dmapreduce.job.maps=$NUM_MAPS -Dmapreduce.job.reduces=$NUM_REDUCERS -Dmapred.map.tasks=$NUM_MAPS -Dmapred.reduce.tasks=$NUM_REDUCERS  /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-input/ /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-output/
        (time ${HADOOP_HOME}/bin/hadoop jar $HSSORT_JAR HSSort -Dmapreduce.job.maps=$NUM_MAPS -Dmapreduce.job.reduces=$NUM_REDUCERS -Dmapred.map.tasks=$NUM_MAPS -Dmapred.reduce.tasks=$NUM_REDUCERS  /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-input/ /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-output/) 2> >(tee ./logs/HSsort-time-run$i.txt) 
        result=$?
    elif [ "$FRAMEWORK" = "Spark" ]; then
        if [ "${SPARK_SCHEDULER}" = "Dcos" ]; then
            echo ${DCOS} spark --name="${SPARK_DCOS_SERVICE_NAME}" run --submit-args="--class HSSort ${sparkopt} ${HSSORT_JAR} /user/${HADOOP_USER}/${HDFS_BENCHMARK_DIR}/HSsort-input/ /user/${HADOOP_USER}/${HDFS_BENCHMARK_DIR}/HSsort-output/"
            jobid=`${DCOS} spark --name="${SPARK_DCOS_SERVICE_NAME}" run --submit-args="--class HSSort ${sparkopt} ${HSSORT_JAR} /user/${HADOOP_USER}/${HDFS_BENCHMARK_DIR}/HSsort-input/ /user/${HADOOP_USER}/${HDFS_BENCHMARK_DIR}/HSsort-output/" | grep "Submission id:" | awk '{print $NF}'`
            result=$?
            if [[ ! -z {jobid} ]]; then 
                (time while [[ `${DCOS} spark --name="${SPARK_DCOS_SERVICE_NAME}" status ${jobid} | grep '"driverState"' | grep -c '"FINISHED"'` -eq 0 ]]; do printf '.'; sleep 5; done) | (tee ./logs/HSsort-time-run${i}.txt)
            fi
        else
            echo ${SPARK_HOME}/bin/spark-submit --class HSSort ${sparkopt} ${HSSORT_JAR} ${spark_fs_prefix}/user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-input/ ${spark_fs_prefix}/user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-output/
            (time ${SPARK_HOME}/bin/spark-submit --class HSSort ${sparkopt} ${HSSORT_JAR} ${spark_fs_prefix}/user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-input/ ${spark_fs_prefix}/user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-output/) 2>&1 | (tee ./logs/HSsort-time-run${i}.txt)
            result=$?
        fi
    fi

    cat ./logs/HSsort-time-run${i}.txt >> ${logfile}

    if [ $result -ne 0 ]
    then
        echo -e "${red}======== HSsort Result FAILURE ========${NC}" | tee -a ${logfile}
        benchmark_result=0
    else
        echo "" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
        echo -e "${green}======== HSsort Result SUCCESS =============${NC}" | tee -a ${logfile}
        echo -e "${green}======== Time taken by HSSort = `grep real ./logs/HSsort-time-run$i.txt | awk '{print $2}'`====${NC}" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
    fi


    echo "" | tee -a ${logfile}
    echo -e "${green}Listing HSsort output ${NC}" | tee -a ${logfile}
    echo "" | tee -a ${logfile}
    ./HSDataCheck.sh ${HADOOP_DEFAULTFS}/user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-output >>  ${logfile}
    if [[ $? -ne 0 ]]; then echo "ERROR !"; exit 9; fi
    echo "" | tee -a ${logfile}

    echo "" | tee -a ${logfile}
    echo "" | tee -a ${logfile}
    echo -e "${green}Starting HSValidate ${NC}" | tee -a ${logfile}
    echo "" | tee -a ${logfile}

    if [ "$FRAMEWORK" = "MapReduce" ]; then
        echo ${HADOOP_HOME}/bin/hadoop jar $HSSORT_JAR HSValidate /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-output/ /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSValidate/
        (time ${HADOOP_HOME}/bin/hadoop jar $HSSORT_JAR HSValidate /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-output/ /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSValidate/) 2> >(tee ./logs/HSvalidate-time-run$i.txt) 
        result=$?
    elif [ "$FRAMEWORK" = "Spark" ]; then
        if [ "${SPARK_SCHEDULER}" = "Dcos" ]; then
            echo ${DCOS} spark --name="${SPARK_DCOS_SERVICE_NAME}" run --submit-args="--class HSValidate ${sparkopt} ${HSSORT_JAR} /user/${HADOOP_USER}/${HDFS_BENCHMARK_DIR}/HSsort-output/ /user/${HADOOP_USER}/${HDFS_BENCHMARK_DIR}/HSValidate/"
            jobid=`${DCOS} spark --name="${SPARK_DCOS_SERVICE_NAME}" run --submit-args="--class HSValidate ${sparkopt} ${HSSORT_JAR} /user/${HADOOP_USER}/${HDFS_BENCHMARK_DIR}/HSsort-output/ /user/${HADOOP_USER}/${HDFS_BENCHMARK_DIR}/HSValidate/" | grep "Submission id:" | awk '{print $NF}'`
            result=$?
            if [[ ! -z {jobid} ]]; then 
                (time while [[ `${DCOS} spark --name="${SPARK_DCOS_SERVICE_NAME}" status ${jobid} | grep '"driverState"' | grep -c '"FINISHED"'` -eq 0 ]]; do printf '.'; sleep 5; done) | (tee ./logs/HSvalidate-time-run${i}.txt)
            fi
        else
            echo ${SPARK_HOME}/bin/spark-submit --class HSValidate ${sparkopt} ${HSSORT_JAR} ${spark_fs_prefix}/user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-output/ ${spark_fs_prefix}/user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSValidate/
            (time ${SPARK_HOME}/bin/spark-submit --class HSValidate ${sparkopt} ${HSSORT_JAR} ${spark_fs_prefix}/user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-output/ ${spark_fs_prefix}/user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSValidate/) 2>&1 | (tee ./logs/HSvalidate-time-run${i}.txt)
            result=$?
        fi
    fi

    cat ./logs/HSvalidate-time-run${i}.txt >> ${logfile}

    if [ $result -ne 0 ]
    then
        echo -e "${red}======== HSsort Result FAILURE ========${NC}" | tee -a ${logfile}
        benchmark_result=0
    else
        echo "" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
        echo -e "${green}======== HSValidate Result SUCCESS =============${NC}" | tee -a ${logfile}
        echo -e "${green}======== Time taken by HSValidate = `grep real ./logs/HSvalidate-time-run$i.txt | awk '{print $2}'`====${NC}" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
    fi

    echo "" | tee -a ${logfile}
    echo -e "${green}Listing HSValidate output ${NC}" | tee -a ${logfile}
    echo "" | tee -a ${logfile}
    ./HSDataCheck.sh ${HADOOP_DEFAULTFS}/user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSValidate >> ${logfile}
    if [[ $? -ne 0 ]]; then echo "ERROR !"; exit 9; fi
    echo "" | tee -a ${logfile}

    echo "" | tee -a ${logfile}
    echo "" | tee -a ${logfile}

    end=`date +%s`

    if [[ ${benchmark_result} -eq 1 ]]; then
        total_time=`expr $end - $start`
        total_time_in_hour=$(echo "scale=4;$total_time/3600" | bc)
        scale_factor=$(echo "scale=4;$hssize/10000000000" | bc)
        perf_metric=$(echo "scale=4;$scale_factor/$total_time_in_hour" | bc)

        echo -e "${green}$sep============${NC}" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
        echo -e "${green}md5sum of core components:${NC}" | tee -a ${logfile}
        md5sum ./TPCx-HS-master.sh ./$HSSORT_JAR ./HSDataCheck.sh ./BigData_cluster_validate_suite.sh | tee -a ${logfile}
        echo "" | tee -a ${logfile}

        echo -e "${green}$sep============${NC}" | tee -a ${logfile}
        echo -e "${green}TPCx-HS Performance Metric (HSph@SF) Report ${NC}" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
        echo -e "${green}Test Run $i details: Total Time = $total_time ${NC}" | tee -a ${logfile}
        echo -e "${green}                     Total Size = $hssize ${NC}" | tee -a ${logfile}
        echo -e "${green}                     Scale-Factor = $scale_factor ${NC}" | tee -a ${logfile}
        echo -e "${green}                     Framework = $FRAMEWORK ${NC}" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
        echo -e "${green}TPCx-HS Performance Metric (HSph@SF): $perf_metric ${NC}" | tee -a ${logfile}
        echo "" | tee -a ${logfile}
        echo -e "${green}$sep============${NC}" | tee -a ${logfile}

    else
        echo -e "${red}$sep${NC}" | tee -a ${logfile}
        echo -e "${red}No Performance Metric (HSph@SF) as some tests Failed ${NC}" | tee -a ${logfile}
        echo -e "${red}$sep${NC}" | tee -a ${logfile}

    fi


done

echo 'grep -e "Time taken by" -e "details: Total Time" -e "Total Size = " -e "Scale-Factor =" -e "TPCx-HS Performance Metric (HSph@SF):" -e "===============================================" TPCx-HS-result-*.log'
