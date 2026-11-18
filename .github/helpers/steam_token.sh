#!/bin/bash
#
# Moves steamcmd's login token (config/config.vdf) in and out of an encrypted file,
# so it can live in the GitHub actions cache. Never prints the token.
#
# restore: decrypt <file> into steamcmd's config.vdf (no-op if <file> is missing)
# save:    encrypt steamcmd's config.vdf into <file>, fail if it holds no login token
#
# Needs STEAM_CACHE_KEY in the environment. Run `steamcmd +quit` once before,
# so steamcmd has bootstrapped and created its config folder.

set -e

if [[ $# -ne 2 || ( "$1" != "restore" && "$1" != "save" ) ]]
then
	echo "Usage: $0 restore|save <encrypted_file>"
	exit 1
fi

MODE="$1"
ENC_FILE="$2"

if [[ -z "${STEAM_CACHE_KEY}" ]]
then
	echo "STEAM_CACHE_KEY is not set"
	exit 1
fi

# steamcmd keeps its data next to steamcmd.sh, ~/Steam is the usual place.
CONFIG_VDF=$(find "${HOME}" "${RUNNER_TOOL_CACHE:-/nonexistent}" -type f -path '*/config/config.vdf' 2>/dev/null | head -n 1)
if [[ -z "${CONFIG_VDF}" ]]
then
	echo "No steamcmd config/config.vdf found"
	exit 1
fi
echo "steamcmd config: ${CONFIG_VDF}"

case ${MODE} in
	restore)
		if [[ ! -f "${ENC_FILE}" ]]
		then
			echo "No cached token, login will need Steam Guard"
			exit 0
		fi
		openssl enc -d -aes-256-cbc -pbkdf2 -pass env:STEAM_CACHE_KEY -in "${ENC_FILE}" -out "${CONFIG_VDF}"
		echo "Token restored"
		;;
	save)
		if ! grep -q "ConnectCache" "${CONFIG_VDF}"
		then
			echo "config.vdf holds no login token, not saving"
			exit 1
		fi
		openssl enc -aes-256-cbc -pbkdf2 -salt -pass env:STEAM_CACHE_KEY -in "${CONFIG_VDF}" -out "${ENC_FILE}"
		echo "Token saved"
		;;
esac
