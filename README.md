# crypt_example_sh
This repository contains a script file for Bash, that describes step-by-step generation of the Metahash address with OpenSSL CLI Tool. For more details about Metahash address generation, please read the [article](https://support.metahash.org/hc/en-us/articles/360002712193-Getting-started-with-Metahash-network#h_683619682421524476003219).

## Get the source code

Clone the repository by:

```shell
git clone https://github.com/metahashorg/crypt_example_sh
```

## Run the script

```shell
./crypt_example.sh generate
```

## Outputs
```shell
Generating private key
Done!
Generating Metahash Addressread EC key
writing EC key
Your Metahash address is 0x0083c...6b
```

```shell
mh.pem - private key file
mh_addr.pub - public key file
```

