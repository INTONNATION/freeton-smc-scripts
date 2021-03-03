#!/bin/bash

set -e

msig="0:cca5ff86bd093b70bc1d139348c69e912e9e69fa581320f090bb039bafe133cc"
msig_keys="./$1.msig.keys.json"
SafeMultisigWalletABI="../ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.abi.json"
DePoolTVC="../ton-labs-contracts/solidity/depool/DePool.tvc"
DePoolABI="../ton-labs-contracts/solidity/depool/DePool.abi.json"
DePoolHelperTVC="../ton-labs-contracts/solidity/depool/DePoolHelper.tvc"
DePoolHelperABI="../ton-labs-contracts/solidity/depool/DePoolHelper.abi.json"
DePoolProxyTVC="../ton-labs-contracts/solidity/depool/DePoolProxy.tvc"

tonos-cli genphrase > $1.depool.seed
tonos-cli genphrase > $1.helper.seed

depool_seed=`cat $1.depool.seed | grep -o '".*"' | tr -d '"'`
helper_seed=`cat $1.helper.seed | grep -o '".*"' | tr -d '"'`

tonos-cli getkeypair $1.depool.keys.json "$depool_seed"
tonos-cli getkeypair $1.helper.keys.json "$helper_seed"

tonos-cli genaddr $DePoolTVC $DePoolABI --setkey $1.depool.keys.json --wc 0 > $1.depool.addr
tonos-cli genaddr $DePoolHelperTVC $DePoolHelperABI --setkey $1.helper.keys.json --wc 0 > $1.helper.addr

depool_addr=`cat $1.depool.addr | grep "Raw address" | awk '{print $3}'`
helper_addr=`cat $1.helper.addr | grep "Raw address" | awk '{print $3}'`

tonos-cli call $msig submitTransaction "{\"dest\":\"$depool_addr\",\"value\":100000000000,\"bounce\":false,\"allBalance\":false,\"payload\":\"\"}" --abi $SafeMultisigWalletABI --sign $msig_keys
tonos-cli call $msig submitTransaction "{\"dest\":\"$helper_addr\",\"value\":100000000000,\"bounce\":false,\"allBalance\":false,\"payload\":\"\"}" --abi $SafeMultisigWalletABI --sign $msig_keys

proxy_code=`tvm_linker decode --tvc $DePoolProxyTVC | grep 'code:' | awk '{print $NF}'`

tonos-cli deploy $DePoolTVC "{\"minStake\":10000000000000, \"validatorAssurance\":10000000000000, \"proxyCode\":\"$proxy_code\", \"validatorWallet\":\"$msig\",\"participantRewardFraction\":99}" --abi $DePoolABI --sign $1.depool.keys.json --wc 0

tonos-cli deploy $DePoolHelperTVC "{\"pool\":\"$depool_addr\"}" --abi $DePoolHelperABI --sign $1.helper.keys.json --wc 0
