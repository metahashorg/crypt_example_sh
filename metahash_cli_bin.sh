#!/bin/bash
# METAHASH CLI TOOL with binary transactions
#
# Usage:
#  $ ./metahash_cli_bin.sh function [parameter]
# * function: Some function to invoke (i.e 'generate', 'usage', 'sign')
# * parameter: function parameter (if any)

scriptname=$0
vars=("$@")


usage () {
    echo -e "Usage: $scriptname function [parameter]"
    echo -e "List of functions:"
    echo -e " \ngenerate -- generate MetaHash address with OpenSSL CLI Tool"
    echo -e " \nusage -- display help info"
    echo -e " \nfetch-balance -- get balance information. Mandatory parameters are: --net=NETWORK(dev|main|test) and --address=metahash_address"
    echo -e " \nfetch-history -- get history for address. Mandatory parameters are: --net=NETWORK(dev|main|test|test) and --address=metahash_address"
    echo -e " \nget-tx -- get transaction information. Mandatory parameters are: --net=NETWORK(dev|main|test) and --tx_hash=transacation_hash"
    echo -e " \nget-address -- get your own metahash address. --net=NETWORK(dev|main|test) and --pubkey=/path/to/public_key are mandatory"
    echo -e " \ngen-transaction -- gives you binary of transaction.\n\tMandatory parameters:"
    echo -e " \t --amount=AMOUNT_TO_SEND,\n \t --send_to=RECEPIENT_ADDRESS --nonce=VALUE"
    echo -e " \nprepare_transaction -- gives you json of transaction.\n\tMandatory parameters:"
    echo -e " \t --net=NETWORK(dev|main|test)\n \t --pubkey=/path/to/public_key\n \t --privkey=/path/to/private_key\n \t --amount=AMOUNT_TO_SEND,\n \t --send_to=RECEPIENT_ADDRESS"
    echo -e "\tOptional parameters: \n \t --nonce=VALUE \n \t --dataHex=DATA_in_HEX"
    echo -e "send_transaction -- send a transaction to server.\n\tMandatory parameters:"
    echo -e " \t --net=NETWORK(dev|main|test)\n \t --pubkey=/path/to/public_key\n \t --privkey=/path/to/private_key\n \t --amount=AMOUNT_TO_SEND,\n \t --send_to=RECEPIENT_ADDRESS"

    exit 1
}

generate () {
openssl ecparam -genkey -name secp256k1 -out mh.pem 2>/dev/null
if [ $? -eq 0 ]; then
        echo -n 'Done! '
else
        echo
        echo 'Something went wrong, check your openssl installation'
        exit 127
fi

openssl ec -in mh.pem -pubout -out mh.pub 2>/dev/null

echo -e 'Private key saved as mh.pem, public as mh.pub in current directory'

get_address_from_pub_key "from_gen"

echo -e "\nYour metahash address is $metahash_address"

}

get_address_from_pub_key () {


        if [[ $1 == 'from_gen' ]] || [ -f mh.pub ] && [ -z $pubkey_file ]
        then
                pubkey_file=mh.pub
        fi

        mh_addr=`mktemp /tmp/mh.XXXXX`

        openssl ec -pubin -inform PEM -in $pubkey_file -outform DER 2>/dev/null |tail -c 65|xxd -p -c 65 >$mh_addr
        sha256hashpub=`cat $mh_addr | xxd -r -p | openssl dgst -sha256 2>/dev/null| cut -f 2 -d ' '`
        rmdhash=00`echo -e $sha256hashpub  | xxd -r -p | openssl dgst -rmd160 | cut -f 2 -d ' '`
        sha256rmdhash=`echo -e $rmdhash | xxd -r -p | openssl dgst -sha256 | cut -f 2 -d ' '`
        sha256hash4=`echo -e  $sha256rmdhash | xxd -r -p | openssl dgst -sha256 | cut -f 2 -d ' '`
        hash4=`echo -e $sha256hash4|head -c 8`
        metahash_address="0x$rmdhash$hash4"
        rm -f $mh_addr
}

fetch-balance () {
  get_config

  if [ -z $address ]
    then
      echo "Address is mandatory parameter, please specify"
      exit 2
  fi

  res=`curl -s -X POST --data '{"id":1,"params":{"address": "'$address'"},"pretty":true}' $torrent_node:$node_port/fetch-balance`

  is_json=`echo $res | grep -q '^{.*result.*}$' ; echo $?`

  if [  $is_json -ne 0 ]
    then
        echo 'not valid json received from server'
     else
        echo $res
  fi


}


fetch-history () {
  get_config

  if [ -z $address ]
    then
      echo "Address is mandatory parameter, please specify"
      exit 2
  fi


  res=`curl -s -X POST --data '{"id":1,"params":{"address": "'$address'"}, "pretty":true}' $torrent_node:$node_port/fetch-history`

  is_json=`echo $res | grep -q '^{.*result.*}$' ; echo $?`

  if [  $is_json -ne 0 ]
    then
        echo 'not valid json received from server'
     else
        echo $res
  fi


}

get-tx () {
  get_config

  if [ -z $tx_hash ]
    then
      echo "tx-hash (transaction hash) is mandatory parameter, please specify"
      exit 2
  fi


  res=`curl -s -X POST --data '{"id":1,"params":{"hash": "'$tx_hash'"},"pretty":true}' $torrent_node:$node_port/get-tx`

  is_json=`echo $res | grep -q '^{.*result.*}$' ; echo $?`

  if [  $is_json -ne 0 ]
    then
        echo 'not valid json received from server'
     else
        echo $res
  fi




}

gen_transaction() {
  function hex_to_endian () {

    endian=''
    i=0

    array=(`echo $1 | grep -o ..`)

      for (( i=${#array[@]}-1 ; i>=0 ; i-- ))
      do
        endian=$endian"${array[i]}"
      done
  }


  for bin in amount fee nonce sizeOfData
  do

    bin_value=${!bin}

    if [ -z $bin_value ]
      then
        res=00

      elif [ $bin_value -lt 250 ]
        then
          hex=`printf "%02x" $bin_value`
          res=$hex
      elif [ $bin_value -le 65535 ]
        then
          hex=`printf "%.4x" $bin_value`
          hex_to_endian $hex
          res="fa$endian"
      elif [ $bin_value -gt 65535 ] && [ $bin_value -le 4294967295 ]
        then
          hex=`printf "%.8x" $bin_value `
          hex_to_endian $hex
          res="fb$endian"
      else
          hex=`printf "%.16x" $bin_value `
          hex_to_endian $hex
          res="fc$endian"
       
      fi

      bin_exp=$bin_exp" $bin->$res "
      bin_data=$bin_data"$res"

  done


  bin_to=`echo $send_to|sed 's/0x//'`

if [ -z $data ]
  then 
    string_to_sign_hex=$bin_to$bin_data
  else
    string_to_sign_hex=$bin_to$bin_data$dataHex
  fi

#echo $string_to_sign_hex


}

prepare_transaction () {
  get_config

  if [ -z $nonce ]
   then
    address=$metahash_address
    count_send=`fetch-balance |grep -o '"count_spent":[0-9]*,i\|"count_spent": [0-9]*,'|grep -o [0-9]*`
    nonce=$((count_send+1))
  fi

  if [ -z $privkey ] || [ ! -f $privkey ]
  then
  echo "private key is mandatory option! please specify --privkey=/path/to/private_key "
  exit 2
  fi

  gen_transaction

  to_sign_temp='/tmp/to_sign'
  signed_temp='/tmp/signed'
  echo $string_to_sign_hex|xxd -r -ps >$to_sign_temp

  to_sign_temp='/tmp/to_sign'
  signed_temp='/tmp/signed'
  cat $to_sign_temp|openssl dgst -sha256 -sign $privkey >$signed_temp 2>/dev/null
  pubkey_der_16=`openssl ec -in $privkey -pubout -outform DER 2>/dev/null|xxd -p|tr -d '\n'`

  openssl dgst -sha256 -verify $pubkey_file -signature $signed_temp $to_sign_temp >/dev/null 2>&1

  if [ $? -ne 0 ]
  then
  echo Failed to verify signed data, exiting
  exit 2
  fi


  signed=`cat $signed_temp|xxd -p|tr -d '\n'`

  json='{
      "jsonrpc": "2.0",
      "method": "mhc_send",
      "params": {
        "to": "'$send_to'",
        "value": "'$amount'",
        "fee": "'$fee'",
        "nonce": "'$nonce'",
        "data": "'$dataHex'",
        "pubkey": "'$pubkey_der_16'",
        "sign": "'$signed'"
    }
 }'


}

send_transaction () {
  prepare_transaction
  echo $json

  res=`curl -s -X POST --data "$json" $proxy_node:$proxy_port`

  is_json=`echo $res | grep -q '^{.*result.*}$' ; echo $?`

  if [  $is_json -ne 0 ]
    then
        echo 'not valid json received from server'
     else
        echo $res
  fi

}

get_config () {

for arg in "${vars[@]}"
do

       p=`echo $arg|cut -f1 -d=`
       value=`echo $arg|cut -f2 -d=`

        case $p in
        --net)
          net=$value
           ;;
        --address)
          address=$value
          ;;
        --tx_hash)
          tx_hash=$value
          ;;
        --pubkey)
          if [ -f $value ]
            then
              pubkey_file=$value
              pubkey=`cat $value`
              get_address_from_pub_key
      else
              echo no public key file $value found
              exit 2
          fi
          ;;
        --privkey)
          if [ -f $value ]
            then
              privkey=$value
            else
              echo no private key file $value found
    exit 2
          fi
          ;;

        --send_to)
          send_to=$value
          ;;
        --amount)
          amount=$value
          ;;
        --nonce)
          nonce=$value
          ;;
        --dataHex)
          dataHex=$value
          data=`echo $dataHex|xxd -r -p`
          #sizeOfData=`echo ${#data}`;
          sizeOfData=`echo $data|awk '{print length}'`
        
          fee=$sizeOfData
          ;;
       esac

done

if [ -z $net ]
 then
      echo "network is mandatory parameter, please specify"
      exit 2
 else
      proxy_node=`dig proxy.net-$net.metahash.org +short +tcp|head -n1`
      torrent_node=`dig tor.net-$net.metahash.org +short +tcp|head -n1`
fi

node_port=5795
proxy_port=9999

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
      get-address)
    get_config
        get_address_from_pub_key
    echo "Your Metahash address is $metahash_address"
    exit 0
    ;;
      fetch-history)
          fetch-history
          exit 0
          ;;
      fetch-balance)
          fetch-balance
          exit 0
          ;;
      get-tx)
          get-tx
          exit 0
          ;;
      gen-tx)
          net=dev
          get_config
          gen_transaction
          echo $string_to_sign_hex
          exit 0
          ;;
      prepare_transaction)
          prepare_transaction
    echo $json

          exit 0
          ;;
      send_transaction)
          send_transaction
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