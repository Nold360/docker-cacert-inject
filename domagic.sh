#!/bin/sh
# This Scripts detects the local package manager & installes
# your CA-certs from /magiccerts/* to the correct place.
# After that the ca-certificates will be updated & a little cleanup

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
set -e
set -u

echo --------------------------
echo "CA Cert Magician working..."
echo --------------------------
env
echo --------------------------
apk_warn() {
    echo .
	echo ' NOTICE: Due to a bug in alpine linux. its only possible to  inject a single CA-Cert atm.'
	echo ' SEE: https://github.com/gliderlabs/docker-alpine/issues/30'
    echo .
}

#   NOTICE: maby only one single cert file is allowed!
install() {
	echo ' -> Installing dependencies...'
	$@
}

config() {
	echo ' -> Injecting Certificates'
	mkdir -pv ${1}
	cp -v /magiccerts/* "${1}/"
}

post() {
	$@
	echo ' -> Success!'
}

# VANISH must be: true | false
clean() {
	echo ' -> Cleaning up...'
	if $VANISH ; then
		rm -rfv /domagic.sh /magiccerts/
		$@
	fi
}

# maybe also: /etc/ssl/certs
# Deb: /usr/local/share/ca-certificates : /usr/sbin/update-ca-certificate
# EL6: /usr/local/share/ca-certificates :  /bin/update-ca-trust enable
# EL7: /etc/pki/ca-trust/source/anchors : /bin/update-ca-trust
# suse: /usr/share/pki/trust/anchors or /usr/share/pki/trust : update-ca-certificates
# alpine: /usr/local/share/ca-certificates :  /usr/sbin/update-ca-certificate

# detect package manager / base distri
for cmd in apk dpkg yum zypper ; do
	find /usr/bin /usr/sbin /bin /sbin -name $cmd | grep -q $cmd || continue
	BASE_DIST=$cmd
	echo " -> ${BASE_DIST}-base detected!"
	break
done

case $BASE_DIST in
	'apk')
		apk_warn
		install apk update && apk add --no-cache ca-certificates
		config /usr/local/share/ca-certificates/
		post update-ca-certificates
		clean
		;;
	'dpkg')
		install apt-get update && apt-get -y --no-install-recommends install ca-certificates
		config /usr/local/share/ca-certificates
		post update-ca-certificates
		clean apt-get clean && clean rm -rf /var/lib/apt/lists/*
		;;
    'yum')
		install 'yum install ca-certificates'
		config /usr/local/share/ca-certificates/
		config /etc/pki/ca-trust/source/anchors/
		post 'update-ca-trust'
		clean 'yum clean all'
		;;
    'zypper')
		install 'zypper install -y --no-recommend ca-certificates'
		config /usr/share/pki/trust
		config /usr/share/pki/trust/anchors
		post 'update-ca-certificates  -v -f'
		clean 'zypper clean'
		;;
	*) echo "BASE_DIST $BASE_DIST unsupported :/" ; exit 1 ;;
esac
exit 0
