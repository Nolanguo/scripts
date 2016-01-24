#!/usr/bin/env python

import os
import sys
import shutil
import pprint

ENVS=['test', 'stage', 'prod']
ROLES=["web","app","varnish","db"]
nagios_conf = {}
temp_hg = {}

def generate_hostname_IP_list(R,E):
	global temp_hg
	hostname = ''
	ip_address = ''
	HOSTLIST=[]
	RESULTS = os.popen('nagios_doit '+ R + ' ' + E + ' -g np')
	for x in RESULTS:
		if x.find('hostname') != -1:
			hostname = x.split("'")[3]
		elif x.find('ip_address') != -1:
			ip_address = x.split("'")[3]

		if hostname and ip_address:
			HOSTLIST.append(hostname+";"+ip_address)
			hostname = ""
			ip_address = ""
	if HOSTLIST:
		generate_nagios_config_files(E,R,HOSTLIST)
		temp_hg[E].append(R)
		return 0
	else:
		return 1

def nagios_host_object(E,h,i):
	if E in ["prod"]:
		contact = 'pager'
		enabled = '1'
	else:
		contact = 'admins'
		enabled = '0'

	host_object = "define host {\n\tuse generic-host" + \
	'\n\thost_name ' + h + \
	'\n\talias ' + h + '.quixey.be' + \
	'\n\taddress ' + i + \
	"\n\tcontact_groups " + contact + \
	"\n\tnotifications_enabled " + enabled + \
	'\n}\n\n'
	return host_object

def nagios_hg_object(E,R,m):
	host_group = "define hostgroup {" + \
	"\n\thostgroup_name " + E + '-' + R + \
	"\n\talias " + E + '-' + R + \
	"\n\tmembers " + m + \
	'\n}\n\n'
	return host_group

def nagios_sg_object(E,R,m):
	# Get the service description based on the Role
	if R == "fastapi-v3":
		service_des = "FastAPI HTTP service"
	elif R == "autosuggest":
		service_des = "Autosuggest"
	elif R == "search-mt-app" or R == "search-mt-ds":
		service_des = "App Search"
	else:
		return 

	# Get members string
	M = ''
	for s in m.split(','):
		M = M + s + ',' + service_des + ','
 
	service_group = "define servicegroup {" + \
	"\n\tservicegroup_name " + E + '-' +  R + '_group' + \
	"\n\talias " + R + '_group for ' + E + \
	"\n\tmembers " + M.rstrip(',') + \
	'\n}\n\n'
	return service_group

def nagios_srv_object(E,L):
	if E in ["prod03"]:
		contact = 'pager'
		enabled = '1'
	else:
		contact = 'admins'
		enabled = '0'

	# Generating hostgroup_name 
	hg_name = ''
	for x in L:
		hg_name = E + '-' + x + ',' + hg_name
	hg_name = hg_name.rstrip(',')

	# Basic services for every host
	service = basic_service(E,L,hg_name,enabled,contact)

	# add other service
	#for r in L:
	#	if r == 'fastapi-v3':
	#		service += fastapi_monitor(E,r,contact,enabled)
	return service

# generating basic services
def basic_service(E,L,hg_name,enabled,contact):
	# Defining service descriptions and their check_command
	SRV_CMD = {'Disk /':'check_remote_nrpe!check_disk!20% 10% /dev/xvda1',
				'Load average':'check_remote_load!20,20,20!30,30,30',
				'Memory Usage':'check_mem!95!98',
				'SSH service':'check_sshd',
				'Splunk service':'check_tcp_port!8089',
				'NRPE service':'check_tcp_port!5666',
				# 'Puppet Agent':'check_puppet'
				}
	DONT_PAGE = ['Splunk service', 'Puppet Agent']
	ori_contact=contact
	ori_enabled=enabled

	# Generate the services
	service=""
	for SRV in SRV_CMD:
		# Do not page Ops if these services have problems
		if SRV in DONT_PAGE:
			contact = 'admins'
			enabled = '0'
		else:
			contact = ori_contact
			enabled = ori_enabled

		service += "define service {" + \
		"\n\tuse                             generic-service" + \
		"\n\thostgroup_name                  " + hg_name + \
		"\n\tservice_description             " + SRV + \
		"\n\tmax_check_attempts              1" + \
		"\n\tnotification_interval           5" + \
		"\n\tnotifications_enabled           " + enabled + \
		"\n\tcheck_command                   " + SRV_CMD[SRV] + \
		"\n\tcontact_groups                  " + contact + \
		'\n}\n\n'
	return service

# nagios services for roles
def fastapi_monitor(E,R,contact,enabled):
		service_obj = "define service {" + \
		"\n\tuse                             generic-service" + \
		"\n\thostgroup_name                  " + E + '-' + R + \
		"\n\tservice_description             FastAPI HTTP service" + \
		"\n\tmax_check_attempts              2" + \
		"\n\tnotification_interval           5" + \
		"\n\tnotifications_enabled           " + enabled + \
		"\n\tcheck_command                   check_health!80" + \
		"\n\tcontact_groups                  " + contact + \
		'\n}\n\n'
		return service_obj

def generate_nagios_config_files(E,R,HOSTLIST):
	global nagios_conf
	temp_hg_member = ''
	for l in HOSTLIST:
		(h,i) = l.split(';')
		nagios_conf[E]['hosts'].append(nagios_host_object(E,h,i))
		temp_hg_member = h + ',' + temp_hg_member
	
	# Generating host groups
	nagios_conf[E]['hostgroups'].append(nagios_hg_object(E,R,temp_hg_member.rstrip(',')))
	
	# Generating service groups for Prod03
	if E == "prod03":
		sg_value = nagios_sg_object(E,R,temp_hg_member.rstrip(','))
		if sg_value:
			nagios_conf[E]['servicegroups'].append(sg_value)

def dump_to_config_file():
	global nagios_conf

	if os.path.exists('quixey'):
		shutil.rmtree('quixey')
	for e in nagios_conf:
		env_dir = 'quixey/' + e
		if not os.path.exists(env_dir):
			os.makedirs(env_dir)
		for x in nagios_conf[e]:
			if x == 'hostgroups':
				FILE=env_dir+'/'+e+'-hostgroups.cfg'
			elif x == 'services':
				FILE=env_dir+'/'+e+'-services.cfg'
			elif x == 'servicegroups':
				FILE=env_dir+'/'+e+'-servicegroups.cfg'
			else:
				FILE=env_dir+'/'+e+'-hosts.cfg'

			F = open(FILE, 'w')
			for l in nagios_conf[e][x]:
				F.write(l)
			F.close()

def main():
	global nagios_conf
	for E in ENVS:
		nagios_conf[E]={'hosts':[],'hostgroups':[],'services':[], 'servicegroups':[]}
		temp_hg[E] = []
		for R in ROLES:
			RET = generate_hostname_IP_list(R, E)
		if RET == 0:
			nagios_conf[E]['services'].append(nagios_srv_object(E,temp_hg[E]))

#	pp = pprint.PrettyPrinter(indent=4)
#	pp.pprint(nagios_conf)
	dump_to_config_file()

if __name__ == '__main__':
	main()
