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
CLASSPATH=`hadoop classpath`
javac -cp $CLASSPATH -d bin TPCx-HS-SRC-MR2/*.java
#javac -cp $CLASSPATH -d bin TPCx-HS-SRC-MR1/*.java
jar -cvf ./jars/TPCx-HS-master_MR1.jar -C bin .
rm -rf bin


if [ ! -d bin ] ;then
  mkdir bin
fi
SPARK_CLASSPATH=/opt/cloudera/parcels/CDH/lib/spark/lib/*
javac -d bin -cp $CLASSPATH:$SPARK_CLASSPATH TPCx-HS-SRC-Spark1.6/src/main/java/*.java
scalac -d bin -cp $CLASSPATH:$SPARK_CLASSPATH:bin  TPCx-HS-SRC-Spark1.6/src/main/scala/*.scala TPCx-HS-SRC-Spark1.6/src/main/java/*.java
jar -cvf ./jars/TPCx-HS-master_Spark.jar -C bin .
rm -rf bin

