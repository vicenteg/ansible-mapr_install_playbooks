Ansible playbooks and roles to install and configure MapR along with selected ecosystem projects, such as Hive, Spark, Drill and OpenTSDB.

This repo contains top level playbooks and git submodules. The submodules mostly provide ansible roles. These must be initialized before running the playbooks.

# Quickstart

```
git clone https://github.com/vicenteg/ansible-mapr_install_playbooks.git my_new_cluster
cd my_new_cluster
git submodule init
git submodule update
cp group_vars/all.example group_vars/all
# Edit group_vars/all to your liking
```

Having edited `group_vars/all`, you can create a cluster in AWS EC2 by running:

```
./makeacluster.sh
```

Or you can inspect the playbooks and roles and execute them as you like. For example, if you have your AWS credentials set up:

```
ansible-playbook mapr_aws_bootstrap.yml
```

Will create some new instances for you in AWS.
