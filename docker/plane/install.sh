#!/bin/bash

clear

cat <<"EOF"


     /////////
     /////////
/////    /////
/////    /////
     ////
     ////

EOF

get_machine_id() {
	if [ -f /etc/machine-id ]; then
		cat /etc/machine-id
	elif [ -f /var/lib/dbus/machine-id ]; then
		cat /var/lib/dbus/machine-id
	else
		echo $(uuidgen)
	fi
}

OS_NAME=$(uname)
CPU_ARCH=$(uname -m)
MACHINE_ID=$(get_machine_id)

SILENT=false
BEHIND_PROXY=false
DOMAIN_NAME=""

while [ "$#" -gt 0 ]; do
	case "$1" in
	--silent)
		SILENT=true
		shift 1
		;;
	--behind-proxy)
		BEHIND_PROXY=true
		shift 1
		;;
	--domain)
		DOMAIN_NAME="$2"
		shift 2
		;;
	--domain=*)
		DOMAIN_NAME="${1#*=}"
		shift 1
		;;
	*)
		echo "Unknown option: $1" >&2
		exit 1
		;;
	esac
done

# check if OS_NAME is not linux or darwin, exit
if [ "${OS_NAME}" != "Linux" ] && [ "${OS_NAME}" != "Darwin" ]; then
	echo "Plane Commercial only works with some flavors of Linux and macOS. See https://developers.plane.so/self-hosting/overview"
	exit 1
fi

if [ -z "${MACHINE_ID}" ]; then
	echo "❌ Machine ID not found ❌"
	exit 1
fi

CLI_DOWNLOAD_RESPONSE=$(curl -sL -H "x-machine-signature: ${MACHINE_ID}" "https://prime.plane.so/api/v2/downloads/cli?arch=${CPU_ARCH}&os=${OS_NAME}" -o ~/prime-cli.tar.gz -w "%{http_code}")

EXTRACTED_DIR="/bin"

if [ "${OS_NAME}" == "Darwin" ]; then
	EXTRACTED_DIR="/usr/local/bin"
fi

if [ $CLI_DOWNLOAD_RESPONSE -eq 200 ]; then
	# Extract the tar.gz file to /bin
	if ! sudo tar -xzf ~/prime-cli.tar.gz -C "${EXTRACTED_DIR}"; then
		echo "Installation failed. Run the curl command again."
		rm -f ~/prime-cli.tar.gz
		exit 1
	fi
	rm -f ~/prime-cli.tar.gz
	sudo prime-cli setup --host="https://prime.plane.so" --behind-proxy="${BEHIND_PROXY}" --silent="${SILENT}" --domain="${DOMAIN_NAME}"
elif [ $CLI_DOWNLOAD_RESPONSE -eq "000" ]; then
	echo "Prime CLI download failed. Run the curl command again."
	echo "Error: $CLI_DOWNLOAD_RESPONSE"
	exit 1
elif [ $CLI_DOWNLOAD_RESPONSE -ge 400 ] && [ $CLI_DOWNLOAD_RESPONSE -lt 500 ]; then
	echo "Prime CLI download failed. Run the curl command again."
	echo "Error: $CLI_DOWNLOAD_RESPONSE"
	exit 1
elif [ $CLI_DOWNLOAD_RESPONSE -ge 500 ] && [ $CLI_DOWNLOAD_RESPONSE -lt 600 ]; then
	echo "Prime CLI download failed. Run the curl command again."
	echo "Error: $CLI_DOWNLOAD_RESPONSE"
	exit 1
else
	echo "Prime CLI download failed. Run the curl command again."
	echo "Error: $CLI_DOWNLOAD_RESPONSE"
	exit 1
fi
