#!/bin/bash

VI="godot/Resources/version_info.txt"

commit=$(git rev-parse --short HEAD)
version=$(git tag --points-at HEAD)
suffix="local"
build=${1:-unknown}
if [ ${version:+1} ]
then
	suffix=$(echo ${version}|cut -d'-' -f2)
	version=$(echo ${version}|cut -d'-' -f1)
else
	version=v0.0.0
fi
echo version ${version}
echo build ${build}
echo suffix ${suffix}

cat <<EOF >${VI}
commit=${commit}
build=${build}
version=${version}
suffix=${suffix}
EOF


cat ${VI}
