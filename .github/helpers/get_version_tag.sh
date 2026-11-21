#!/bin/bash

# Prints the highest version tag on HEAD, or nothing if there is none.
# Only full versions count: vX.Y.Z, three numbers, nothing else.
# Floating tags like `classic`, `v3` or `v3.16` are ignored.
git tag --points-at HEAD --list 'v[0-9]*' --sort=-version:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1
