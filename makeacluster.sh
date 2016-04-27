#!/usr/bin/env bash

#user=centos
user=ec2-user
mount=/media/ephemeral0
vault_password_file="vault_pass"

if test -f $vault_password_file; then
	VAULT_PASS_OPT="--vault-password-file=$vault_password_file"
fi

time (
	if ! test -f "inventory.py" || ! ansible -i inventory.py -u $user -m ping all; then
		echo -n "Press CTRL-C within 5 seconds if you don't want new instances..."
		sleep 5
		echo

		ansible-playbook $VAULT_PASS_OPT mapr_aws_bootstrap.yml || exit 1
		ansible-playbook -i inventory.py -u $user wait.yml || exit 1
		ansible-playbook -i inventory.py -u $user opt_mapr.yml || exit 1

		# CentOS 6 HVM AMI housekeeping
		# Wait a bit for cloudinit to finish (presumably)
		sleep 10
		ansible -i inventory.py -su $user -m mount -a "src=/dev/xvdf name=/media/ephemeral0 state=absent fstype=ext3" all
	fi

	ansible-playbook -i inventory.py -u $user wait.yml
	ansible-playbook -f 10 -i inventory.py -u $user $VAULT_PASS_OPT mapr_install.yml
	./printurls.sh
)
