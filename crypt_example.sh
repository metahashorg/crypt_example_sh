#!/bin/bash


# METAHASH CLI TOOL
#
# Usage:
#  $ ./crypt_example.sh function [parameter]
# * function: Some function to invoke (i.e 'generate', 'usage', 'sign')
# * parameter: function parameter (if any)



scriptname=$0


usage () {
    echo "Usage: $scriptname function [parameter]"
    echo "   List of functions:"
    echo "	generate -- generate MetaHash address with OpenSSL CLI Tool"
    echo "	usage -- display help info"
    exit 1
}



generate () {
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
echo -n 'Generating Metahash Address'
openssl ec -in mh.pem -pubout -outform DER|tail -c 65|xxd -p -c 65 > mh_addr.pub
sha256hashpub=`cat mh_addr.pub | xxd -r -p | openssl dgst -sha256`
rmdhash=00`echo -e $sha256hashpub  | xxd -r -p | openssl dgst -rmd160`
sha256rmdhash=`echo -e $rmdhash | xxd -r -p | openssl dgst -sha256`
sha256hash4=`echo -e  $sha256rmdhash | xxd -r -p | openssl dgst -sha256`
hash4=`echo -e $sha256hash4|head -c 4`
echo "Your Metahash address is 0x$rmdhash$hash4"
}




while :
do
    case "$1" in
      -h | --help)
          usage
          exit 0
          ;;
      usage)
	  usage
          exit 0
          ;;
      generate)
          generate
          exit 0
          ;;
      -*)
          echo "Error: Unknown option: $1" >&2
          usage
          exit 1
          ;;
      *)  # No more options
          echo "Error: Unknown option: $1" >&2
	  usage
          exit 1
          ;;
    esac
done


"$@"
