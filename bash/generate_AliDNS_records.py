#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import aliyun.connection
import quixeycloud

reload(sys)
sys.setdefaultencoding('utf8')

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
	host = 'A,'
	result = ECS_conn.get_instance(x)
	host += result.hostname
	host += ",默认,"
	host += str(result.public_ip_addresses[0])
	host += ",,600"
	output[x] = host

for x in output:
	print output[x]
