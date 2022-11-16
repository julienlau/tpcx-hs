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
#

usage()
{
    echo usage: $0 [-v <version>]
}

while getopts "hv:" OPTION; do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        v)
            OPT_VERSION=$OPTARG
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done
      
DEFAULT_VERSION="`date +%Y%m%d-%H%M%S`-dev"
VERSION=${OPT_VERSION:-$DEFAULT_VERSION}
ARCHIVE="TPCx-HS_Kit_v$VERSION"
STAGING_DIR=/tmp
VERSION_FILE=../TPCx-HS-Runtime-Suite/VERSION.txt
SPEC_DOC="../TPCx-HS Specification.docx"

SPEC_VERSION=2.3.0
if [ -x /usr/bin/textutil ]; then
    SPEC_VERSION=`/usr/bin/textutil -convert txt -stdout "$SPEC_DOC" | fgrep Version | head -1 | cut -d' ' -f2`
fi


echo "Building TPCx-HS Kit Version $VERSION"
echo "VERSION.txt:"
echo "   OLD=`cat $VERSION_FILE`" 
echo "$VERSION" > $VERSION_FILE
echo "   NEW=`cat $VERSION_FILE`" 
echo "Spec Version: $SPEC_VERSION"
[ "$SPEC_VERSION" != "$VERSION" ] && echo " *** WARNING: Spec and Kit version do not match! ***"
echo

if [[ "${SPEC_VERSION}" != "$(grep 'version :=' TPCx-HS-SRC-Spark/build.sbt | awk '{print $NF}' | tr -d '\"')" ]]; then
    echo "ERROR version mismatch check TPCx-HS-SRC-Spark/build.sbt"
    grep "version :=" TPCx-HS-SRC-Spark/build.sbt | awk '{print $NF}' | tr -d '"'
    exit 2705
fi

[ -d "$STAGING_DIR/$ARCHIVE" ] && rm -r "$STAGING_DIR/$ARCHIVE"

mkdir -p "$STAGING_DIR/$ARCHIVE"
cp ../EULA.txt "$STAGING_DIR/$ARCHIVE"
cp "../TPCx-HS Specification.docx" "$STAGING_DIR/$ARCHIVE"
cp -r ../TPCx-HS-Runtime-Suite "$STAGING_DIR/$ARCHIVE"
cp -r ../TPCx-HS-SRC "$STAGING_DIR/$ARCHIVE"

echo "==== Generating ${STAGING_DIR}/${ARCHIVE}.zip ===="
(cd $STAGING_DIR && zip -r -X "${ARCHIVE}.zip" "$ARCHIVE")

rm -rf "$STAGING_DIR/$ARCHIVE"
