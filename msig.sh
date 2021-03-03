#!/bin/bash

# NOW SUPPORTS ONLY FLD NETWORK

set -e

SafeMultisigWalletABI="../ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.abi.json"
SafeMultisigWalletTVC="../ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.tvc"
Marvin=0:deda155da7c518f57cb664be70b9042ed54a92542769735dfb73d3eef85acdaf

tonos-cli genphrase > $1.msig.seed
seed=`cat $1.msig.seed | grep -o '".*"' | tr -d '"'`
echo "seed - $seed"
tonos-cli genpubkey "$seed" > $1.msig.pub
pub=`cat $1.msig.pub | grep "Public key" | awk '{print $3}'`
echo "pub - $pub"
tonos-cli getkeypair $1.msig.keys.json "$seed"
tonos-cli genaddr $SafeMultisigWalletTVC $SafeMultisigWalletABI --setkey $1.msig.keys.json --wc 0 > $1.msig.addr
addr=`cat $1.msig.addr | grep "Raw address" | awk '{print $3}'`
echo "addr $addr"
wget https://raw.githubusercontent.com/FreeTON-Network/fld.ton.dev/main/scripts/Marvin.abi.json
tonos-cli call "$Marvin" grant "{\"addr\":\"$addr\"}" --abi Marvin.abi.json
tonos-cli deploy $SafeMultisigWalletTVC "{\"owners\":[\"0x$pub\"],\"reqConfirms\":1}" --abi $SafeMultisigWalletABI --sign $1.msig.keys.json --wc 0
tonos-cli account $addr
