#!/bin/bash

PROJECT="fiiish-v3"
TEMPLATE_FOLDER="steam"

set -e

if [[ $# -ne 2 ]]
then
	echo "Usage: $0 <target_folder> <sub_type>"
	exit 1
fi

TARGET_FOLDER="$1"

SUB_TYPE="$2"

case ${SUB_TYPE} in
	demo-classic)
		;;
	classic)
		;;
	demo)
		;;
	*)
		echo "Error: Invalid sub_type ${SUB_TYPE}"
		exit 1
		;;
esac

echo "SUB_TYPE: ${SUB_TYPE}"

if [[ ! -d ${TARGET_FOLDER} ]]
then
	echo "Error: TARGET_FOLDER ${TARGET_FOLDER} does NOT exist"
	exit 1
fi

# cd ${TARGET_FOLDER}
PLATFORMS=("macos" "windows" "linux")
VERSIONS=()
ANY_ERROR=false
for PLATFORM in "${PLATFORMS[@]}"
do
	# echo ${PLATFORM}
	VERSION_FILE="${TARGET_FOLDER}/${PROJECT}-${PLATFORM}-${SUB_TYPE}/version.txt"
	if [[ ! -f ${VERSION_FILE} ]]
	then
		echo "Error: version.txt for ${PLATFORM} NOT found"
		ANY_ERROR=true
	fi
	VERSION=$(cat ${VERSION_FILE})
	if [[ "x${VERSION}" == "x" ]]
	then
		echo "Error: version for ${PLATFORM} NOT set"
		ANY_ERROR=true
	fi
	echo "${PLATFORM} ${VERSION}"
	VERSIONS+=("${VERSION}")
done

if ${ANY_ERROR}
then
	echo "ANY_ERROR ${ANY_ERROR}"
	exit -1
fi

echo "Versions:"
echo ${VERSIONS[@]}

VERSION_MISMATCH=false
VERSION="${VERSIONS[0]}"
for V in "${VERSIONS[@]}"
do
	if [[ "${V}" != "${VERSION}" ]]
	then
		VERSION_MISMATCH=true
	fi
done

if ${VERSION_MISMATCH}
then
	echo "Version mismatch!"
	exit -1
fi

echo "---"

cat "steam/templates/AppBuild_${SUB_TYPE}.vdf"| sed "s/\[DESC\]/v${VERSION}/g" >"${TARGET_FOLDER}/AppBuild_${SUB_TYPE}.vdf"
cp steam/templates/DepotBuild_${SUB_TYPE}_*.vdf "${TARGET_FOLDER}"

# DepotBuild_demo-classic_macos.vdf

