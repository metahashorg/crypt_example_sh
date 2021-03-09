# crypt_example_sh
This repository contains a script file for Bash, that describes step-by-step generation of the Metahash address, creating transactions and fetching balance history and information. For more details about Metahash address generation, please read the [article](https://developers.metahash.org/hc/en-us/articles/360002712193-Getting-started-with-Metahash-network#h_683619682421524476003219). More details about how to create transactions and perform other operations with an address you can find by following these links: [Creating transactions](https://developers.metahash.org/hc/en-us/articles/360003271694-Creating-transactions) and [Operations with MetaHash address](https://developers.metahash.org/hc/en-us/articles/360008382213-Operations-with-MetaHash-address).

## Get the source code

Clone the repository by:

```shell
git clone https://github.com/metahashorg/crypt_example_sh
```

## Run the script

```shell
./metahash_cli_bin.sh function [parameter]

List of functions:

	generate  - generate MetaHash address with OpenSSL CLI Tool

	usage  - display help info
	
	fetch-balance -- get balance information. Mandatory parameters are: --net=NETWORK(dev|main|test) and --address=metahash_address

	fetch-history -- get history for address. Mandatory parameters are: --net=NETWORK(dev|main|test) and --address=metahash_address

	get-tx -- get transaction information. Mandatory parameters are: --net=NETWORK(dev|main|test) and --tx_hash=transacation_hash

	get-address -- get your own metahash address. --net=NETWORK(dev|main|test) and --pubkey=/path/to/public_key are mandatory

	prepare_transaction -- gives you json of transaction.
	
		Mandatory parameters:
 	 		 --net=NETWORK(dev|main|test)
		 	 --pubkey=/path/to/public_key (optional)
		 	 --privkey=/path/to/private_key or pass directly your private key in hex format, ie --privkey=309010101021041....
		 	 --amount=AMOUNT_TO_SEND,
		 	 --send_to=RECEPIENT_ADDRESS
		Optional parameters:
 	 		 --nonce=VALUE
			 --dataHex=DATA_in_HEX (only test net)

	send_transaction -- send a transaction to server.
	
		Mandatory parameters:
		 	 --net=NETWORK(dev|main|test)
		 	 --pubkey=/path/to/public_key (optional)
		 	 --privkey=/path/to/private_key  or pass directly your private key in hex format, ie --privkey=309010101021041....
		 	 --amount=AMOUNT_TO_SEND,
		 	 --send_to=RECEPIENT_ADDRESS
		Optional parameters:
			 --dataHex=DATA_in_HEX (only test net)
```

## Outputs
```shell
mh.pem - private key file
mh.pub - public key file
```
### Output Example
```shell
#./metahash_cli_bin.sh generate

Done! Your private key saved as mh.pem, public as mh.pub in current directory

Your metahash address is 0x0055b025b3f8464f29082871618379a5062f10b88021f00e69

#./metahash_cli fetch-balance --net=dev --address=0x0055b025b3f8464f29082871618379a5062f10b88021f00e69
{
    "id": 1,
    "result": {
        "address": "0x0055b025b3f8464f29082871618379a5062f10b88021f00e69",
        "received": 0,
        "spent": 0,
        "count_received": 0,
        "count_spent": 0,
        "block_number": 0,
        "currentBlock": 1346
    }
}

# ./metahash_cli fetch-history --net=dev --address=0x0055b025b3f8464f29082871618379a5062f10b88021f00e69
{
    "id": 1,
    "result": [
        {
            "from": "0x0074bcb34e85b717dc3bf356001c7e733209572c9eaf138628",
            "to": "0x0055b025b3f8464f29082871618379a5062f10b88021f00e69",
            "value": 25000,
            "transaction": "0b1fad6ff9f66fd6b2592cf64ea18017954a03690309d98f7956374f8bb5ef4d",
            "timestamp": 1528903124
        }
    ]
}


# ./metahash_cli  send_transaction --net=dev --pubkey=./mh.pub --send_to=0x0074bcb34e85b717dc3bf356001c7e733209572c9eaf138628 --amount=6666  --privkey=./mh.pem
{ "jsonrpc": "2.0", "method": "mhc_send", "params": { "to": "0x0074bcb34e85b717dc3bf356001c7e733209572c9eaf138628", "value": "6666", "fee": "", "nonce": "1", "data": "", "pubkey": "3056301006072a8648ce3d020106052b8104000a034200041128541b832e6d6687249f9189737a568a4ce6df01dc7cdaa28f5ee7c7ae64cc227b50ed2408791584ffea585612c804f9a789850157e94e5dddaf12ee06fcc8", "sign": "30460221009171303840866375b4ca2743302dfa865250a7aede7b719e91fbaa358299947802210097ee0462adc2f2e5bb70d4e0b8545c8d860b29a472be24e4ea4d6c9521baa3dc" } }
{"result":"ok","params":"1d7f80e13ef2e14a848cbf0712436c8263fedf6cf23a29cfae70c00f38217951"}


#./metahash_cli get-tx --net=dev --tx_hash=6b7657f9dafc629466bf7f40f1caa5eba8a75eff132b51e86bb791c9e765fef2
{
    "id": 1,
    "result": {
        "transaction": {
            "from": "0x0055b025b3f8464f29082871618379a5062f10b88021f00e69",
            "to": "0x0074bcb34e85b717dc3bf356001c7e733209572c9eaf138628",
            "value": 666,
            "transaction": "6b7657f9dafc629466bf7f40f1caa5eba8a75eff132b51e86bb791c9e765fef2",
            "timestamp": 0
        }
    }
}


#./metahash_cli  prepare_transaction --net=dev --pubkey=./mh.pub --send_to=0x0074bcb34e85b717dc3bf356001c7e733209572c9eaf138628 --amount=6666  --privkey=./mh.pem
{ "jsonrpc": "2.0", "method": "mhc_send", "params": { "to": "0x0074bcb34e85b717dc3bf356001c7e733209572c9eaf138628", "value": "6666", "fee": "", "nonce": "1", "data": "", "pubkey": "3056301006072a8648ce3d020106052b8104000a03420004dd6e2237ed7158995bb8247235b68b5f1e86efafd9e64a72dca8695782b9ff4cedf68da23f8865ec01f12b4bfe59157737baf339cc0bf4e1a00781149db1ac17", "sign": "304502210080fe3ab30adf14ef38ce63e8cb871cbab9834b3c4c3edc15aeef44cb00540a6f02206492179cc18d605e038336be10f7c0af83a2ca1437a1f0fdbce28a7aa01e6aef" } }


```

