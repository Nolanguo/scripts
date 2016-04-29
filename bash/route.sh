#!/bin/bash

# This routing table works in conjuction with badvpn-tun2socks
#
# Maintainer: Nolan Guo <gyce2008@gmail.com>
# 

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# The tunnel device name
TUN=tun8

# The gateway of the tunnel device
HKT=172.16.0.2

# add the route for these specific hosts
# HK VPN Server
route add -host x.x.x.x metric 0 dev ppp0

# LAN & Local VPN network
route add -net  192.168.0.0/16 metric 0 dev p4p1

# DNS servers overseas
route add -host x.x.x.x metric 0 gw $HKT
route add -host x.x.x.x metric 0 gw $HKT
route add -host 8.8.8.8 metric 0 gw $HKT

# Lowering the priority of the defaute gateway
route del default
route add -net 0.0.0.0/0 metric 100 dev ppp0

# Routing all traffic destined to 0.0.0.1 ~ 31.255.255.255 via the HK tunnel. 
# Most of them are in US
route add -net 0.0.0.0/3 metric 90 gw $HKT

# Google Inc.
route add -net 172.217.0.0/16 metric 80 gw $HKT
route add -net 173.194.0.0/16 metric 80 gw $HKT
route add -net 74.125.0.0/16 metric 80 gw $HKT
route add -net 104.237.199.0/24 metric 70 gw $HKT

# facebook
route add -net 243.185.187.0/24 metric 70 gw $HKT
route add -net 173.252.74.0/24 metric 70 gw $HKT

# Youtube
route add -net 216.58.0.0/16 metric 80 gw $HKT

# Twitter
route add -net 199.59.0.0/16 metric 80 gw $HKT
route add -net 104.244.43.0/24 metric 70 gw $HKT
route add -net 104.244.42.0/24 metric 70 gw $HKT

# wikipedia.org
route add -net 198.35.26.0/24 metric 70  gw $HKT
route add -net 159.106.121.0/24 metric 70  gw $HKT

# nytimes.com
route add -net 52.84.206.0/24 metric 70 gw $HKT
route add -net 54.182.2.0/24 metric 70 gw $HKT


# Akamai cdn
route add -net 62.156.209.0/24 metric 60 gw $HKT

# specific hosts
route add -host 107.178.245.188 metric 50 gw $HKT
route add -net 94.31.29.0/24 metric 70 gw $HKT
route add -net 104.154.47.0/24 metric 70 gw $HKT

# VPN related
route add -net 192.185.45.0/24 metric 70 gw $HKT
route add -net 130.158.6.0/24 metric 70 gw $HKT

# others
route add -net 50.118.208.0/24 metric 70 gw $HKT
route add -net 50.31.164.0/24 metric 70 gw $HKT
route add -net 208.111.148.0/24 metric 70 gw $HKT
route add -net 37.61.54.0/24 metric 70 gw $HKT
