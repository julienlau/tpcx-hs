
Compiling the source code
=========================
By running the following command the source files are compiled to create the TPCx-HS-master_MR2.jar
and the TPCx-HS-master_Spark.jar in the jars directory:
./compile.sh

Distribution
============
The compiled jar files need to be moved into the TPCx-HS-Runtime-Suite directory for distribution.
By running the following command, all the necessary docs and jars get bundled into a zip file:
./build.sh
