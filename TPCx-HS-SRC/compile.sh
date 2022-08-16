#
# Copyright (C) 2015 Transaction Processing Performance Council (TPC) and/or
# its contributors.
#
# This file is part of a software package distributed by the TPC.
#
# The contents of this file have been developed by the TPC, and/or have been
# licensed to the TPC under one or more contributor license agreements.
#
# This file is subject to the terms and conditions outlined in the End-User
# License Agreement (EULA) which can be found in this distribution (EULA.txt)
# and is available at the following URL:
# http://www.tpc.org/TPC_Documents_Current_Versions/txt/EULA.txt
#
# Unless required by applicable law or agreed to in writing, this software
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied, and the user bears the entire risk as
# to quality and performance as well as the entire cost of service or repair
# in case of defect.  See the EULA for more details.
#
#/

if [ ! -d jars ] ;then
  mkdir jars 
fi

if [ ! -d bin ] ;then
  mkdir bin
fi
HADOOPVERSION=2
CLASSPATH=`hadoop classpath`
echo
echo "Compiling TPCx-HS-SRC-MR${HADOOPVERSION}"
echo
javac -cp $CLASSPATH -d bin TPCx-HS-SRC-MR${HADOOPVERSION}/*.java
jar -cvf ./jars/TPCx-HS-master_MR${HADOOPVERSION}.jar -C bin .
rm -rf bin


if [ ! -d bin ] ;then
  mkdir bin
fi
#SPARK_CLASSPATH=/opt/spark-1.6.3-bin-hadoop2.6/lib/*
SPARK_CLASSPATH=/opt/spark/lib/*
echo
echo "Compiling TPCx-HS-SRC-Spark"
echo

if [[ ! -z $(which sbt 2>/dev/null) ]] ; then
    echo
    echo "Compiling FatJar with sbt for TPCx-HS-SRC-Spark"
    echo
    cd TPCx-HS-SRC-Spark && \
    sbt assembly && \
    cd .. && \
    mv TPCx-HS-SRC-Spark/target/scala-*/TPCx-HS-master_Spark_*.jar jars/.
else
    javac -d bin -cp $CLASSPATH:$SPARK_CLASSPATH TPCx-HS-SRC-Spark/src/main/java/*.java
    scalac -d bin -cp $CLASSPATH:$SPARK_CLASSPATH:bin TPCx-HS-SRC-Spark/src/main/scala/*.scala TPCx-HS-SRC-Spark/src/main/java/*.java
    jar -cvf ./jars/TPCx-HS-master_Spark.jar -C bin .
    rm -rf bin

    echo
    echo "Skipping FatJar for TPCx-HS-SRC-Spark"
    echo
fi

ls -lart $(pwd)/jars
