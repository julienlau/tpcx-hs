
Compiling the source code
=========================
By running the following command the source files are compiled to create the TPCx-HS-master_MR2.jar
and the TPCx-HS-master_Spark.jar in the jars directory:
* You may need to edit variable SPARK_CLASSPATH
* You may need scala to compile Spark application
* Update SPEC_VERSION in build.sh
* Update version in TPCx-HS-SRC-Spark/build.sbt
* Check scala version in TPCx-HS-SRC-Spark/build.sbt
* ./compile.sh
* When running Spark on DC/OS:
       - a fatjar is needed
       - you will need to install scala build tool "sbt" if you want ./compile.sh to generate a fatjar
       - you will need to deploy the fatjar on hdfs yourself using for example : 
         `hdfs dfs -copyFromLocal jars/TPCx-HS-master_Spark-assembly-2.0.3.jar /spark_jar/TPCx-HS-master_Spark.jar`


Distribution
============
The compiled jar files need to be moved into the TPCx-HS-Runtime-Suite directory for distribution.
By running the following command, all the necessary docs and jars get bundled into a zip file:
./build.sh

Docker image
============
A docker image for Spark + Hadoop that does not include tpcxhs application jar can be built using `TPCx-HS-SRC-Spark/Dockerfile`
