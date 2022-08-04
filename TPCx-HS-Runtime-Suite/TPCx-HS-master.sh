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

shopt -s expand_aliases
source ./Benchmark_Parameters.sh

VERSION=`cat ./VERSION.txt`
MR_HSSORT_JAR="TPCx-HS-master_MR2.jar"
SPARK_HSSORT_JAR="TPCx-HS-master_Spark.jar"

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
   -g  <TPCx-HS Scale Factor option from below>
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

   Example: $0 -m -g 2

EOF
}

while getopts "hmsg:" OPTION; do
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
         g)  sze=$OPTARG
 			 case $sze in
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
         ?)  echo -e "${red}Please choose a vlaid option${NC}"
             usage
             exit 2
             ;;
    esac
done

if [ -z "$FRAMEWORK" ]; then
    echo
    echo "Please specify the framework to use (-m or -s)"
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


if [ -f ./TPCx-HS-result-"$prefix".log ]; then
   mv ./TPCx-HS-result-"$prefix".log ./TPCx-HS-result-"$prefix".log.`date +%Y%m%d%H%M%S`
fi

echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}Running $prefix test${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}HSsize is $hssize${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}All Output will be logged to file ./TPCx-HS-result-$prefix.log${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log

## CLUSTER VALIDATE SUITE ##


if [ $CLUSTER_SHELL -eq 1 ]
then
   echo -e "${green}$sep${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
   echo -e "${green} Running Cluster Validation Suite${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
   echo -e "${green}$sep${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
   echo "" | tee -a ./TPCx-HS-result-"$prefix".log
   echo "" | tee -a ./TPCx-HS-result-"$prefix".log

   source ./BigData_cluster_validate_suite.sh | tee -a ./TPCx-HS-result-"$prefix".log

   echo "" | tee -a ./TPCx-HS-result-"$prefix".log
   echo -e "${green} End of Cluster Validation Suite${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
   echo "" | tee -a ./TPCx-HS-result-"$prefix".log
   echo "" | tee -a ./TPCx-HS-result-"$prefix".log
else
   echo -e "${red}CLUSH NOT INSTALLED for cluster audit report${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
   echo -e "${red}To install clush follow USER_GUIDE.txt${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
fi

## BIGDATA BENCHMARK SUITE ##

# Note for 1TB (1000000000000), input for HSgen => 10000000000 (so many 100 byte words)

sudo -u $HDFS_USER hadoop fs -mkdir /user
sudo -u $HDFS_USER hadoop fs -mkdir /user/"$HADOOP_USER"
sudo -u $HDFS_USER hadoop fs -chown "$HADOOP_USER":"$HADOOP_USER" /user/"$HADOOP_USER"

hadoop fs -ls "${HDFS_BENCHMARK_DIR}"
if [ $? != 0 ] ;then
  hadoop fs -mkdir "${HDFS_BENCHMARK_DIR}"
fi

for i in `seq 1 2`;
do

benchmark_result=1

echo -e "${green}$sep${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}Deleting Previous Data - Start - `date`${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
hadoop fs -rm -r -skipTrash /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/*
sudo -u $HDFS_USER hadoop fs -expunge
sleep $SLEEP_BETWEEN_RUNS
echo -e "${green}Deleting Previous Data - End - `date`${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}$sep${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log

start=`date +%s`
echo -e "${green}$sep${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green} Running BigData TPCx-HS Benchmark Suite ($FRAMEWORK) - Run $i - Epoch $start ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green} TPCx-HS Version $VERSION ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}$sep${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}Starting HSGen Run $i (output being written to ./logs/HSgen-time-run$i.txt)${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log


mkdir -p ./logs
if [ "$FRAMEWORK" = "MapReduce" ]; then
    (time hadoop jar $HSSORT_JAR HSGen -Dmapreduce.job.maps=$NUM_MAPS -Dmapreduce.job.reduces=$NUM_REDUCERS -Dmapred.map.tasks=$NUM_MAPS -Dmapred.reduce.tasks=$NUM_REDUCERS $hssize /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-input) 2> >(tee ./logs/HSgen-time-run$i.txt) 
else
    (time spark-submit --class HSGen --deploy-mode ${SPARK_DEPLOY_MODE} --master ${SPARK_MASTER_URL} --conf "spark.driver.memory=${SPARK_DRIVER_MEMORY}" --conf "spark.executor.memory=${SPARK_EXECUTOR_MEMORY}" --conf "spark.executor.cores=${SPARK_EXECUTOR_CORES}" --conf "spark.executor.instances=${SPARK_EXECUTOR_INSTANCES}" ${HSSORT_JAR} ${hssize} /user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-input ) 2>&1 | (tee ./logs/HSgen-time-run${i}.txt)
fi
result=$?

cat ./logs/HSgen-time-run${i}.txt >> ./TPCx-HS-result-"$prefix".log

if [ $result -ne 0 ]
then
echo -e "${red}======== HSgen Result FAILURE ========${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
benchmark_result=0
else
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}======== HSgen Result SUCCESS ========${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}======== Time taken by HSGen = `grep real ./logs/HSgen-time-run$i.txt | awk '{print $2}'`====${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
fi

echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}Listing HSGen output ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
./HSDataCheck.sh /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-input | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log

echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}Starting HSSort Run $i (output being written to ./logs/HSsort-time-run$i.txt)${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log

if [ "$FRAMEWORK" = "MapReduce" ]; then
    (time hadoop jar $HSSORT_JAR HSSort -Dmapreduce.job.maps=$NUM_MAPS -Dmapreduce.job.reduces=$NUM_REDUCERS -Dmapred.map.tasks=$NUM_MAPS -Dmapred.reduce.tasks=$NUM_REDUCERS  /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-input /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-output) 2> >(tee ./logs/HSsort-time-run$i.txt) 
else
    (time spark-submit --class HSSort --deploy-mode ${SPARK_DEPLOY_MODE} --master ${SPARK_MASTER_URL} --conf "spark.driver.memory=${SPARK_DRIVER_MEMORY}" --conf "spark.executor.memory=${SPARK_EXECUTOR_MEMORY}"  --conf "spark.executor.cores=${SPARK_EXECUTOR_CORES}" --conf "spark.executor.instances=${SPARK_EXECUTOR_INSTANCES}" ${HSSORT_JAR} /user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-input /user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-output) 2>&1 | (tee ./logs/HSsort-time-run${i}.txt)
fi
result=$?

cat ./logs/HSsort-time-run${i}.txt >> ./TPCx-HS-result-"$prefix".log

if [ $result -ne 0 ]
then
echo -e "${red}======== HSsort Result FAILURE ========${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
benchmark_result=0
else
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}======== HSsort Result SUCCESS =============${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}======== Time taken by HSSort = `grep real ./logs/HSsort-time-run$i.txt | awk '{print $2}'`====${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
fi


echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}Listing HSsort output ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
./HSDataCheck.sh /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-output | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log

echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}Starting HSValidate ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log

if [ "$FRAMEWORK" = "MapReduce" ]; then
    (time hadoop jar $HSSORT_JAR HSValidate /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSsort-output /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSValidate) 2> >(tee ./logs/HSvalidate-time-run$i.txt) 
else
    (time spark-submit --class HSValidate --deploy-mode ${SPARK_DEPLOY_MODE} --master ${SPARK_MASTER_URL} --conf "spark.driver.memory=${SPARK_DRIVER_MEMORY}" --conf "spark.executor.memory=${SPARK_EXECUTOR_MEMORY}" --conf "spark.executor.cores=${SPARK_EXECUTOR_CORES}" --conf "spark.executor.instances=${SPARK_EXECUTOR_INSTANCES}" ${HSSORT_JAR} /user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSsort-output /user/"${HADOOP_USER}"/"${HDFS_BENCHMARK_DIR}"/HSValidate) 2>&1 | (tee ./logs/HSvalidate-time-run${i}.txt)
fi
result=$?

cat ./logs/HSvalidate-time-run${i}.txt >> ./TPCx-HS-result-"$prefix".log

if [ $result -ne 0 ]
then
echo -e "${red}======== HSsort Result FAILURE ========${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
benchmark_result=0
else
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}======== HSValidate Result SUCCESS =============${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}======== Time taken by HSValidate = `grep real ./logs/HSvalidate-time-run$i.txt | awk '{print $2}'`====${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
fi

echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}Listing HSValidate output ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
./HSDataCheck.sh /user/"$HADOOP_USER"/"${HDFS_BENCHMARK_DIR}"/HSValidate | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log

echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log

end=`date +%s`

if (($benchmark_result == 1))
then
total_time=`expr $end - $start`
total_time_in_hour=$(echo "scale=4;$total_time/3600" | bc)
scale_factor=$(echo "scale=4;$hssize/10000000000" | bc)
perf_metric=$(echo "scale=4;$scale_factor/$total_time_in_hour" | bc)

echo -e "${green}$sep============${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}md5sum of core components:${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
md5sum ./TPCx-HS-master.sh ./$HSSORT_JAR ./HSDataCheck.sh ./BigData_cluster_validate_suite.sh | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log

echo -e "${green}$sep============${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}TPCx-HS Performance Metric (HSph@SF) Report ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}Test Run $i details: Total Time = $total_time ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}                     Total Size = $hssize ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}                     Scale-Factor = $scale_factor ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}                     Framework = $FRAMEWORK ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}TPCx-HS Performance Metric (HSph@SF): $perf_metric ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo "" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${green}$sep============${NC}" | tee -a ./TPCx-HS-result-"$prefix".log

else
echo -e "${red}$sep${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${red}No Performance Metric (HSph@SF) as some tests Failed ${NC}" | tee -a ./TPCx-HS-result-"$prefix".log
echo -e "${red}$sep${NC}" | tee -a ./TPCx-HS-result-"$prefix".log

fi


done
