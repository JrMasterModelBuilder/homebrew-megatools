#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

url='https://megatools.megous.com/builds/LATEST'
expected='megatools-1.11.1.20230212'

version="$(curl -k -f -L -s "${url}")"
if [[ "${version}" == "${expected}" ]]; then
	echo "Verified version"
else
	echo "Unexpect version: ${version}"
	exit 1
fi
