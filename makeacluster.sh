#!/usr/bin/env bash

user=centos
#user=ec2-user
mount=/media/ephemeral0
vault_password_file="vault_pass"

OPTS=$(getopt --long skipvalidation --long verbose --long testonly --long skiptests -o "vt" -- "$@")
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$OPTS"

SKIP_TAGS=

while true ; do
	case "$1" in
		-v|--verbose)
			VERBOSE="-vv"
			echo "verbose on." ;
			shift ;;
		--skipvalidation)
			SKIP_TAGS="$SKIP_TAGS,validation"
			echo "skipping validation.";
			shift ;;
		--skiptests)
			SKIP_TAGS="$SKIP_TAGS,test"
			echo "skipping tests.";
			shift ;;
		-t|--testonly)
			TESTONLY="--tags test"
			echo "Running test tags" ;
			shift ;;
		--) shift ; break ;;
		*) echo "Internal error!" ; exit 1 ;;
	esac
done

[ ! -z $SKIP_TAGS ] && SKIP_TAGS="--skip-tags=$SKIP_TAGS"

if test -f $vault_password_file; then
	VAULT_PASS_OPT="--vault-password-file=$vault_password_file"
fi

time (
	if ! test -f "inventory.py" || ! ansible $VERBOSE -i inventory.py -u $user -m ping all; then
		echo -n "Press CTRL-C within 5 seconds if you don't want new instances..."
		sleep 5
		echo

		ansible-playbook $VERBOSE $VAULT_PASS_OPT mapr_aws_bootstrap.yml || exit 1
		ansible-playbook $VERBOSE -i inventory.py -u $user wait.yml || exit 1

		# CentOS 6/7 HVM AMI housekeeping
		# Wait a bit for cloudinit to finish (presumably)
		sleep 15
		ansible $VERBOSE -i inventory.py -su $user -m mount -a "src=/dev/xvdf name=/media/ephemeral0 state=absent fstype=ext3" all
		ansible-playbook $VERBOSE -i inventory.py -u $user opt_mapr.yml || exit 1
	fi

	ansible-playbook $VERBOSE -i inventory.py -u $user wait.yml && \
		ansible-playbook $TESTONLY $VERBOSE $SKIP_TAGS -f 10 -i inventory.py -u $user $VAULT_PASS_OPT mapr_install.yml && \
		./printurls.sh
)
