#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

url='https://xff.cz/megatools/builds/LATEST'
expected='megatools-1.11.5.20250706'
exprefix='megatools-'

torhost='127.0.0.1'
torport='9950'
torctrl='9951'
torprox="socks5://${torhost}:${torport}"
torpass=''

torcmd() {
	printf 'AUTHENTICATE "%s"\r\n%s\r\n' "${torpass}" "$1" |\
		nc "${torhost}" "${torctrl}" 2>/dev/null
}

torprogress() {
	local progress='0'
	local bootstrap=$(torcmd 'GETINFO status/bootstrap-phase')
	if [[ "${bootstrap}" == *'PROGRESS='* ]]; then
		local part="${bootstrap#*PROGRESS=}"
		progress="${part%% *}"
	fi
	printf '%s' "${progress}"
}

torwait() {
	local prev=''
	local curr='0'
	while true; do
		curr="$(torprogress)"
		if [[ "${curr}" != "${prev}" ]]; then
			echo "Tor progress: ${curr}%"
			prev="${curr}"
		fi
		if [[ "${curr}" == '100' ]]; then
			break
		fi
		sleep 0.1
	done
}

tornew() {
	torcmd 'SIGNAL NEWNYM'
	torwait
}

torcurl() {
	curl --proxy "${torprox}" "$@"
}

cleanup() {
	if [[ "${torpass}" != '' ]]; then
		echo 'Tor shutdown...'
		torcmd 'SIGNAL SHUTDOWN'
		torpass=''
	fi
}

trap cleanup EXIT INT TERM

response=''
for i in {1..10}; do
	echo "Attempt: ${i}"
	if [[ "${i}" == 2 ]]; then
		torpass="$(uuidgen)"
		tor \
			--RunAsDaemon 1 \
			--SocksPort "${torport}" \
			--ControlPort "${torctrl}" \
			--HashedControlPassword "$(tor --hash-password "${torpass}")"
		torcmd 'GETINFO status/bootstrap-phase'
		torwait
	fi

	curlcmd='curl'
	if [[ "${i}" != 1 ]]; then
		if [[ "${i}" != 2 ]]; then
			tornew
		fi
		curlcmd='torcurl'
	fi

	response="$("${curlcmd}" -v --max-time 5 -k -f -L -s "${url}" || true)"
	if [[ "${response}" == "${exprefix}"* ]]; then
		break
	fi
done
echo "RESPONSE: ${response}"

if [[ "${response}" == "${expected}" ]]; then
	echo 'PASS: Verified version'
else
	echo 'FAIL: Unexpect version'
	exit 1
fi
