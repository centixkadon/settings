#!/bin/bash

ssserver -c /etc/shadowsocks/config.json --forbidden-ip 127.0.0.1/32,::1/128 --manager-address 127.0.0.1:11110 $* 2>&1 |grep -v "server already exists" |tee -a ~/All/log/shadowsocks.log
