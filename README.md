# crypt_example_sh
This repository contains a script file for Bash, that describes step-by-step generation of the Metahash address, creating transactions and fetching balance history and information. For more details about Metahash address generation, please read the [article](https://support.metahash.org/hc/en-us/articles/360002712193-Getting-started-with-Metahash-network#h_683619682421524476003219).

## Get the source code

Clone the repository by:

```shell
git clone https://github.com/metahashorg/crypt_example_sh
```

## Run the script

```shell
./crypt_example.sh function [parameter]

List of functions:

	generate  - generate MetaHash address with OpenSSL CLI Tool

	usage  - display help info
	
	fetch-balance -- get balance information. Mandatory parameters are: --net=NETWORK(dev|main) and --address=metahash_address

	fetch-history -- get history for address. Mandatory parameters are: --net=NETWORK(dev|main) and --address=metahash_address

	get-tx -- get transaction information. Mandatory parameters are: --net=NETWORK(dev|main) and --tx_hash=transacation_hash

	get-address -- get your own metahash address. --net=NETWORK(dev|main) and --pubkey=/path/to/public_key are mandatory

	prepare_transaction -- gives you json of transaction.
	
		Mandatory parameters:
 	 		 --net=NETWORK(dev|main)
		 	 --pubkey=/path/to/public_key
		 	 --privkey=/path/to/private_key
		 	 --amount=AMOUNT_TO_SEND,
		 	 --send_to=RECEPIENT_ADDRESS
		Optional parameters:
 	 		--nonce=VALUE

	send_transaction -- send a transaction to server.
	
		Mandatory parameters:
		 	 --net=NETWORK(dev|main)
		 	 --pubkey=/path/to/public_key
		 	 --privkey=/path/to/private_key
		 	 --amount=AMOUNT_TO_SEND,
		 	 --send_to=RECEPIENT_ADDRESS
```

## Outputs
```shell
mh.pem - private key file
mh.pub - public key file
```
### Output Example
```shell
./crypt_example.sh generate

Generating private key
Done!
Generating Metahash Addressread EC key
Your Metahash address is 0x0083c...6b

and two files with private and public keys: ./mh.pem ./mh.pub

```

