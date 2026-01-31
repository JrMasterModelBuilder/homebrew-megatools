#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

url='https://xff.cz/megatools/builds/LATEST'
expected='megatools-1.11.5.20250706'

version="$(curl -v -k -f -L -s "${url}")"
if [[ "${version}" == "${expected}" ]]; then
	echo "Verified version"
else
	echo "Unexpect version: ${version}"
	exit 1
fi
