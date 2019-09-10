#!/bin/bash
info="usage:\n sh client_key.sh USER_NAME EMAIL \n Run this script in directory to store your keys"

if [ $1 ];	then
	if [ $2 ]; then
		NAME=$1
		MAIL=$2
		echo "generating keys for $NAME $MAIL ..."
	else
		echo $info
		exit 1
	fi
else
	echo $info
	exit 1
fi

mkdir -p private && mkdir -p cacerts && mkdir -p certs

keyfile="private/"$NAME"Key.pem"

certfile="certs/"$NAME"Cert.pem"

p12file=$NAME".p12"

strongswan pki --gen --type rsa --size 2048 \
	--outform pem \
	> $keyfile

strongswan pki --pub --in $keyfile --type rsa | \
	strongswan pki --issue --lifetime 730 \
	--cacert cacerts/strongswanCert.pem \
	--cakey private/strongswanKey.pem \
	--dn "C=CH, O=DARKGOD-ONLINE, CN=$MAIL" \
	--san $MAIL \
	--outform pem > $certfile

strongswan pki --print --in $certfile

echo "\nEnter password to protect p12 cert for $NAME"
openssl pkcs12 -export -inkey $keyfile \
	-in $certfile -name "$NAME's VPN Certificate" \
	-certfile cacerts/strongswanCert.pem \
	-caname "strongSwan Root CA" \
	-out $p12file

if [ $? -eq 0 ]; then
	echo "cert for $NAME at $p12file"
fi
