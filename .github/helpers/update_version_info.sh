#!/bin/bash

VI="godot/Resources/version_info.txt"

commit=$(git rev-parse --short HEAD)
version=$(git tag --points-at HEAD)
suffix="local"
build=${1:-unknown}
if [ ${version:+1} ]
then
	version=$(echo ${version}|cut -d'-' -f1)
	suffix=""
	# suffix=$(echo ${version}|cut -d'-' -f2)
else
	version=v0.0.0
	suffix="unknown"
	echo "Contains HEAD"
	git tag -l --contains HEAD
	echo "Points At HEAD"
	git tag --points-at HEAD
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

echo ${PWD}
echo ${VI}
cat ${VI}
