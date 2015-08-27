user=ec2-user
mount=/media/ephemeral0
vault_password_file="vault_pass"

if test -f $vault_password_file; then
	VAULT_PASS_OPT="--vault-password-file=$vault_password_file"
fi

time (
	if ! test -f "inventory.py" || ! ansible -i inventory.py -u $user -m ping all; then
		ansible-playbook $VAULT_PASS_OPT mapr_aws_bootstrap.yml
		ansible-playbook -i inventory.py -u $user wait.yml

		# CentOS 6 HVM AMI housekeeping
		# Wait a bit for cloudinit to finish (presumably)
		sleep 10
		# create a new volume to mount on /opt/mapr
		ansible -i inventory.py -su $user -m mount -a "src=/dev/xvdf name=/media/ephemeral0 state=absent fstype=ext3" all
		ansible -i inventory.py -su $user -a "mkfs.ext4 /dev/xvdb" cluster
		ansible -i inventory.py -su $user -m mount -a "src=/dev/xvdb name=/opt/mapr state=present fstype=ext4" cluster
		ansible -i inventory.py -su $user -m mount -a "src=/dev/xvdb name=/opt/mapr state=mounted fstype=ext4" cluster

		# back to our regular program - optionally update packages
		# ansible -i inventory.py -su $user -m shell -a "http_proxy=http://172.16.1.58:3128 yum -y update" all
		# ansible -i inventory.py -su $user -a "shutdown -r now" all
	fi

	ansible-playbook -i inventory.py -u $user wait.yml
	ansible-playbook -i inventory.py -su $user $VAULT_PASS_OPT mapr_install.yml
)
