#!/bin/bash
#
# Logs steamcmd into Steam, leaving a valid login token in steamcmd's config.vdf.
#
# 1. Username only: uses the cached token (see steam_token.sh), no Steam Guard.
#    Passing the password would force a fresh password login and Steam Guard.
# 2. Fallback, username and password: Steam Guard asks for a phone confirmation (~1 min).
#
# Afterwards `steamcmd +login "${STEAM_USER}" ...` works without password.
# Needs STEAM_USER and STEAM_PASSWORD in the environment.

set -o pipefail

if [[ -z "${STEAM_USER}" || -z "${STEAM_PASSWORD}" ]]
then
	echo "STEAM_USER and STEAM_PASSWORD must be set"
	exit 1
fi

LOG="${RUNNER_TEMP:-/tmp}/steam_login.log"

echo "Trying cached login"
if timeout 120 steamcmd +login "${STEAM_USER}" +quit < /dev/null 2>&1 | tee "${LOG}" \
	&& ! grep -q -E "FAILED|password:" "${LOG}"
then
	echo "Cached login OK"
	exit 0
fi

echo "Cached login failed, falling back to password login (Steam Guard: confirm on the phone)"
steamcmd +login "${STEAM_USER}" "${STEAM_PASSWORD}" +quit < /dev/null
