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
set -x
mypath=$1
mypath=${mypath%%/}

if [[ "${STORAGE_BACKEND}" == "hdfs" ]]; then
    hdfs dfs ${hdfsopt} -ls $mypath/*
    if [[ $? -ne 0 ]]; then echo "ERROR ! $0 ls"; exit 9; fi
    # NB this file is not created if spark.hadoop.mapreduce.fileoutputcommitter.marksuccessfuljobs=false
    hdfs dfs ${hdfsopt} -ls $mypath/_SUCCESS
    if [[ $? -ne 0 ]]; then echo "ERROR ! $0 file _SUCCESS not found"; exit 9; fi
elif [[ "${STORAGE_BACKEND}" == "s3a" ]]; then
    #mc ls --recursive $mypath
    rclone ls $mypath
    if [[ $? -ne 0 ]]; then echo "ERROR ! $0 ls"; exit 9; fi
    #mc ls $mypath/_SUCCESS
    rclone ls $mypath/_SUCCESS | grep _SUCCESS
    if [[ $? -ne 0 ]]; then echo "ERROR ! $0 file _SUCCESS not found"; exit 9; fi
else
    echo "$0 : STORAGE_BACKEND not supported ${STORAGE_BACKEND}"
    exit 9
fi
