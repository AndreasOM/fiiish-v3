#!/bin/bash

BUCKET="artifacts.omnimad.net"
PROJECT="fiiish-v3"

set -e

if [[ $# -ne 2 ]]
then
	echo "Usage: $0 <target_folder> <build_type>"
	exit 1
fi

TARGET_FOLDER="$1"

BUILD_TYPE="$2"
PLATFORM=""

case ${BUILD_TYPE} in
	macos*)
		PLATFORM="macos"
		;;
	linux*)
		PLATFORM="linux"
		;;
	windows*)
		PLATFORM="windows"
		;;
	*)
		echo "Error: Unsupported BUILD_TYPE: ${BUILD_TYPE}"
		exit 1
		;;
esac

SUB_TYPE=""

case ${BUILD_TYPE} in
	*-demo-classic)
		SUB_TYPE="demo-classic"
		;;
	*-classic)
		SUB_TYPE="classic"
		;;
	*-demo)
		SUB_TYPE="demo"
		;;
esac

echo "PLATFORM: ${PLATFORM} SUB_TYPE: ${SUB_TYPE}"

mkdir -p ${TARGET_FOLDER}
cd ${TARGET_FOLDER}

LATEST_FILE="${PROJECT}-${BUILD_TYPE}-latest.txt"
S3_LATEST_FILE="s3://${BUCKET}/${PROJECT}/${LATEST_FILE}"

echo "Downloading latest file from ${S3_LATEST_FILE}"

aws s3 cp ${S3_LATEST_FILE} ${LATEST_FILE} || {
	echo "Error: Failed to download latest file"
	exit 1
}

LATEST=$(cat "${LATEST_FILE}")
if [[ "x${LATEST}" == "x" ]]
then
	echo "Error: ${LATEST_FILE} is empty"
	exit 1
fi

#
# split into parts
#
#ARCHIVE_FOLDER=$( dirname "${LATEST}" )
#ARCHIVE_NAME=$( basename "${LATEST}" .tgz )
#ARCHIVE_EXT=.tgz
#
# combine
#
#ARCHIVE_FILE="${ARCHIVE_NAME}${ARCHIVE_EXT}"

ARCHIVE_NAME=$( basename "${LATEST}" )
S3_ARCHIVE_FILE="s3://${BUCKET}/${LATEST}"

if [[ "x${ARCHIVE_NAME}" == "x" ]]
then
	echo "Error: ARCHIVE_NAME is empty"
	exit 1
fi

if [[ -f ${ARCHIVE_NAME} ]]
then
	echo "Skipping download since local file exists"
else
	echo "Syncing latest archive from ${S3_ARCHIVE_FILE} to ${ARCHIVE_NAME}"

	aws s3 cp ${S3_ARCHIVE_FILE} ${ARCHIVE_NAME} || {
		echo "Error: Failed to download latest archive"
		exit 1
	}
fi

echo "Extracting archive"

tar xzf ${ARCHIVE_NAME} || {
	echo "Error: Failed to extract archive"
	exit 1
}

VERSION_FILE="${PROJECT}-${PLATFORM}-${SUB_TYPE}/version.txt"
VERSION=""
if [[ -f ${VERSION_FILE} ]]
then
	VERSION=$(cat ${VERSION_FILE})
else
	echo "Error: No version.txt in archive"
	exit 1
fi

echo "Version: ${VERSION}"

if [[ ${GITHUB_ENV} != "" ]]
then
	echo "GITHUB_ENV is set"
	if [[ -f ${GITHUB_ENV} ]]
	then
		echo "GITHUB_ENV file exists"
		{
			echo "${PLATFORM}_VERSION=${VERSION}"
		} >> "${GITHUB_ENV}"
	else
		echo "GITHUB_ENV file does NOT exist"
	fi
fi
