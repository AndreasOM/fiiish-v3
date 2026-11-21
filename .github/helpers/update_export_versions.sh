#!/bin/bash

# Writes the version and the build number into the files the Godot export reads.
# The numeric part of the version becomes the project version,
# which macOS, iOS and Windows exports use as the user-visible version.
# The build number becomes the bundle version of the macOS and iOS exports.

set -euo pipefail

VERSION=${1:?Usage: update_export_versions.sh <version> <build number>}
BUILD_NUMBER=${2:?Usage: update_export_versions.sh <version> <build number>}

PROJECT_FILE="godot/project.godot"
PRESETS_FILE="godot/export_presets.cfg"

NUMERIC_VERSION=${VERSION#v}
NUMERIC_VERSION=${NUMERIC_VERSION%%-*}

if [[ ! ${NUMERIC_VERSION} =~ ^[0-9]+(\.[0-9]+)*$ ]]
then
	echo "::error::Version '${VERSION}' has no numeric part like 1.2.3"
	exit 1
fi

if ! grep -q '^config/version=' ${PROJECT_FILE}
then
	echo "::error::No config/version in ${PROJECT_FILE}"
	exit 1
fi

if ! grep -q '^application/version=""$' ${PRESETS_FILE}
then
	echo "::error::No empty application/version in ${PRESETS_FILE}"
	exit 1
fi

sed -i.bak -E "s|^config/version=.*|config/version=\"${NUMERIC_VERSION}\"|" ${PROJECT_FILE}
sed -i.bak -E "s|^application/version=\"\"$|application/version=\"${BUILD_NUMBER}\"|" ${PRESETS_FILE}
rm -f ${PROJECT_FILE}.bak ${PRESETS_FILE}.bak

grep -n '^config/version=' ${PROJECT_FILE}
grep -n '^application/version=' ${PRESETS_FILE}
