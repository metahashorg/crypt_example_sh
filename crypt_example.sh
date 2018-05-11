#!/bin/bash
echo -n 'Generating private key'

openssl ecparam -genkey -name secp256k1 -out mh.pem

if [ $? -eq 0 ]; then
	echo
	echo -n 'Done!'
else 
	echo
	echo 'Something went wrong, check your openssl installation'
	exit 127
fi

echo 
echo


echo -n 'Generating Metahash Address'



openssl ec -in mh.pem -pubout -outform DER|tail -c 65|xxd -p -c 65 > mh_addr.pub
sha256hashpub=`cat mh_addr.pub | xxd -r -p | openssl dgst -sha256`
rmdhash=00`echo -e $sha256hashpub  | xxd -r -p | openssl dgst -rmd160`
sha256rmdhash=`echo -e $rmdhash | xxd -r -p | openssl dgst -sha256`
sha256hash4=`echo -e  $sha256rmdhash | xxd -r -p | openssl dgst -sha256`
hash4=`echo -e $sha256hash4|head -c 4`
echo "Your Metahash address is 0x$rmdhash$hash4"
