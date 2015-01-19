#!/bin/bash

. /etc/profile

ssh $1 '
hostname
echo
cat /etc/issue
uname -a
echo
rpm -q bash
'
