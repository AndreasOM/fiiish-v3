#!/bin/bash

VI="godot/Resources/version_info.txt"

commit=$(git rev-parse --short HEAD)
version=$(git tag --points-at HEAD)
suffix="local"
build=${1:-unknown}
if [ ${version:+1} ]
then
	version=v0.0.0
else
	suffix="TODO"
fi
echo ${build}
echo ${suffix}

cat <<EOF >${VI}
commit=${commit}
build=${build}
version=${version}
suffix=${suffix}
EOF
