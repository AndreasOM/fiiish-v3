#!/bin/sh

VI="godot/Resources/version_info.txt"

commit=$(git rev-parse --short HEAD)
version=$(git tag --points-at HEAD)
suffix="local"
build=${1:-unknown}
if [ "X${version}" == "X" ]
then
	version=v0.0.0
else
	suffix="TODO"
fi
echo ${build}

cat <<EOF >${VI}
commit=${commit}
build=${build}
version=${version}
suffix=${suffix}
EOF
