#!/usr/bin/python
import argparse
import json
import logging
import pprint
import sys

logger = logging.getLogger()

import aliyun.connection
import quixeycloud

# Define Cloud & Region
CLOUD = 'aliyun'
REGION = 'cn-hangzhou'
ZK = 'zookeeper.quixey.be:2181/Hosts'
output = {}

# Create cloud connection
C = quixeycloud.create_cloud_interface(CLOUD)
ecs_conn = C.get_ec_connection(REGION)

# Create zookeeper registry connection
reg = C.get_registry_connection(ZK, REGION)

# Get all ECS instances
ECS_instances = ecs_conn.get_all_instance_ids()

# Connect to ECS instance
ECS_conn = ecs_conn.conn

for x in ECS_instances:
	host = ''
	tags = ''
	result = ECS_conn.get_instance(x)
	host += str(result.internal_ip_addresses).strip("[u']")
	host += "," + str(result.public_ip_addresses).strip("[u']")
	host += "," + result.hostname.strip("[u']")
	host += "," + result.instance_type.strip("[u']")
	tags = reg.instance(x)['tags']
	for a in tags:
		if a[0] in ['role', 'env']:
			host += ',' + a[1]
	output[x] = host

for x in output:
	print x + ',' + output[x]
