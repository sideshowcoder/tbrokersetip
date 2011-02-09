#!/usr/bin/env bash

# NOTE:  tbrokersetip.sh requires the tbrokersetip.cfg configuration file to run.
# Place the tbrokersetip.cfg file in your home directory or use the -c option for a custom location.

# Scriptlayout based on Todo.sh http://todotxt.com

VERSION="0.7"
version() {
	cat <<-EndVersion
				Tunnelbroker set IPv4 Tunnelendpoint v$VERSION

				First release: 2/9/2011
				Author: Philipp Fehre (http://sideshowcoder.com)
				License: BSD, http://www.opensource.org/licenses/bsd-license.php
								<OWNER> = Author
								<YEAR> = 2011
				Code repository: http://github.com/sideshowcoder/
		EndVersion
	exit 1
}

usage() {
	cat <<-EndUsage
				Usage: $(basename "$0") [-hv] [-c CONFIGPATH]
				-h	help
				-v	version
				-c	pass config path
			EndUsage
	exit 1
}

die() {
	echo "$*"
	exit 1
}

# check if config is passed
while getopts 'vhc:' OPTION
do
	case $OPTION in
		c )	
			TB_CONFIG=$OPTARG
			;;
		v )
			version
			;;
		h )
			usage
			;;
		? )	
			usage
			;;
	esac
done

# set and read config either default or set
TB_CONFIG=${TB_CONFIG:-$HOME/tbrokersetip.cfg}
[ -r "$TB_CONFIG" ] || die "config $TB_CONFIG not readable"
. "$TB_CONFIG" 

# get the current ipv4 address if not set and prepare password
if [ -z $TB_IPV4 ]; then
	# thanks for the reqexp to http://linux.byexamples.com/archives/307/what-is-my-public-ip-address/
	TB_IPV4=$(curl -s http://checkip.dyndns.org | egrep -m1 -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
fi
MD5PASS=$(md5 -qs $TB_PASS)

# run curl to set the ip see https://ipv4.tunnelbroker.net/ipv4_end.php for details
curl -sk "https://ipv4.tunnelbroker.net/ipv4_end.php?ipv4b=$TB_IPV4&pass=$MD5PASS&user_id=$TB_USERID&tunnel_id=$TB_GTUNID"
EXIT=$?
echo
exit $EXIT