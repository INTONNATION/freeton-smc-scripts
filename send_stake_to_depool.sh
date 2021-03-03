#!/bin/bash

depool_addr=`cat $1.depool.addr | grep "Raw address" | awk '{print $3}'`
msig_addr=`cat $1.msig.addr | grep "Raw address" | awk '{print $3}'`
msig_seed=`cat $1.msig.seed | grep -o '".*"' | tr -d '"'`

tonos-cli depool --addr $depool_addr stake ordinary --wallet $msig_addr --value 99500 --sign "$msig_seed"
