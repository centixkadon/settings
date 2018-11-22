#!/bin/bash

cd ~/All/git/github/shadowsocks/shadowsocks-manager
node server.js -c sscount.yml $*
