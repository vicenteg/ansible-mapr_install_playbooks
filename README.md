Ansible playbooks and roles to install and configure MapR along with selected ecosystem projects, such as Hive, Spark, Drill and OpenTSDB.

This repo contains top level playbooks and git submodules. The submodules mostly provide ansible roles. These must be initialized before running the playbooks.

# Quickstart

```
git clone https://github.com/vicenteg/ansible-mapr_install_playbooks.git my_new_cluster
cd my_new_cluster
git submodule update --init
cp group_vars/all.example group_vars/all
# Edit group_vars/all to your liking
```

Ensure that your AWS credentials and default region are set.  This can be done by adding the following to your ```~/.bashrc```
and reloading it with ```source ~/.bashrc```:

```
# Edit these
AWS_ACCESS_KEY="YOURACCESKEYHEREABCDEF"
AWS_SECRET_KEY="xxBZYZVZD11R1dnpqAA2mnga82F0tb00bd15Geef"

# Not these
AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY"
AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY"

# Set to your preferred region
AWS_DEFAULT_REGION="us-west-2"

export AWS_ACCESS_KEY AWS_ACCESS_KEY_ID AWS_SECRET_KEY AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION
```

Having done the above and edited `group_vars/all`, being sure to substitute your AWS details, you
can create a cluster in AWS EC2 by running:

```
./makeacluster.sh
```

Or you can inspect the playbooks and roles and execute them as you like. For example, if you have your AWS credentials set up:

```
ansible-playbook mapr_aws_bootstrap.yml
```

Will create some new instances for you in AWS and leave an inventory script behind that you can use to do further things in ansible:


See if the nodes are up:

```
ansible -i inventory.py -m ping cluster
```

Update packages:

```
ansible -i inventory.py -a "yum -y update" all

```

## Troubleshooting

Here are a few problems that may arise and how to fix them.

### Old or nonexistent versions of python-boto

If you see one of the following errors:
```
boto required for this module
TypeError: __init__() got an unexpected keyword argument 'encrypted'\n"
```
Try installing or upgrading your version of python-boto.  This can be done with ```pip upgrade python-boto```.

### Old versions of ansible

If you see the error:
```
ERROR: provided hosts list is empty
```
Try upgrading your version of ansible.  Follow the [instructions here](http://docs.ansible.com/ansible/intro_installation.html).

### No credentials configured

If you see the error:

```
No handler was ready to authenticate. 
```

It means that no AWS credentials were configured.  Review the above section to set the required environment variables or check [this page](http://docs.ansible.com/ansible/guide_aws.html) for more detailed instructions.

### AMI configuration errors

Consult [this page at Amazon](http://docs.aws.amazon.com/autoscaling/latest/userguide/ts-as-instancelaunchfailure.html)
for more information on troubleshooting EC2 instance launch failures.

### Setting the time and timezone

This error:

```
Failure talking to yum: Cannot retrieve metalink for repository: epel/x86_64. Please verify its path and try again
```
is most likely due to the local time, on the machine from which you are running the playbook, not being set or set to UTC.
Check the local time and retry.  On Ubuntu systems
you can use the following command: ```sudo dpkg-reconfigure tzdata```.
