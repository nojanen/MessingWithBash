#!/bin/bash
#
# Add a SSL certificate to Java's trusted CA Certificates
#

APPS_JAVA="$JAVA_HOME"
KEYTOOL="$APPS_JAVA/bin/keytool"
KEYSTORE_FILE="$APPS_JAVA/jre/lib/security/cacerts"
OPENSSL="openssl"



function get_certificate {

        local HOST="$1"
        [ -z $HOST ] && echo "get_certificate: No HOST given" && exit 1

	echo "" | $OPENSSL s_client -prexit -connect "$HOST" 2>/dev/null | $OPENSSL x509 
}

function check_certificate {

	local CERT="$1"
	[ -z "$CERT" ] && echo "check_certificate: No CERT given" && exit 1

	echo "$CERT" | $OPENSSL x509 -text
}

function get_certificate_startdate {

        local CERT="$1"
        [ -z "$CERT" ] && echo "get_certificate_date: No CERT given" && exit 1
	local STARTDATE="$(echo "$CERT" | $OPENSSL x509 -startdate -noout | sed 's/notBefore=//')"

	if [ "$(sw_vers -productName)" = "Mac OS X" ]
	then
		date -j -f "%b %d %T %Y %Z" "$STARTDATE" +%Y%m%d
	else
		date -d "$STARTDATE" +'%Y%m%d'
	fi
}

function add_certificate_to_trustore {

	local CERT="$1"
	local NAME="$2"
	local STOREPASS
	local STOREOWNER
	[ -z "$CERT" ] && echo "add_certificate_to_trustore: No CERT given" && exit 1
	[ -z "$NAME" ] && echo "add_certificate_to_trustore: No NAME given" && exit 1

	read -p "Password for trustore [changeit]: " STOREPASS
	STOREPASS=${STOREPASS:-changeit}

	read -p "Username used for updating trustore [root]: " STOREOWNER
	STOREOWNER=${STOREOWNER:-root}

	sudo -u "$STOREOWNER" $KEYTOOL -keystore $KEYSTORE_FILE -importcert -noprompt -trustcacerts -storepass "$STOREPASS" -alias "$NAME" <<< "$CERT"
}


##   ##  ####  #### ##  ##
### ### ##  ##  ##  ### ##
## # ## ######  ##  ## ###
##   ## ##  ## #### ##  ##

echo "Add a SSL certificate to Java's trusted CA Certificate store ($KEYSTORE_FILE) "
read -p "Give HOST of new certificate: " SSL_HOST
read -p "Give PORT of new certificate [443]: " SSL_PORT
SSL_PORT=${SSL_PORT:-443}

CERTIFICATE=$(get_certificate "$SSL_HOST:$SSL_PORT")

check_certificate "$CERTIFICATE"

read -p "Do you want to add this certificate to Java trustore? [yN] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	add_certificate_to_trustore "$CERTIFICATE" "${SSL_HOST}_$(get_certificate_startdate "$CERTIFICATE")"
	echo "New certificate is installed"
else
	echo "Cancelled"
fi

