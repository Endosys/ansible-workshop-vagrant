# RHEL 8 Ansible Workshop class build out VM

Vagrantfile with buildout configuration for a Virtualbox VM with RHEL 8 server-desktop and configuration for building out an ansible workshop within AWS

## Requirements
1. [VirtualBox & Extension Pack](https://www.virtualbox.org/)
1. [Vagrant](https://www.vagrantup.com/)
1. vagrant-vbguest
    ```sh
    vagrant plugin install vagrant-vbguest 
    ```
1. To register with subscription-manager a free RedHat Developer subscription is required. This Vagrantfile expects to find the credentials in environment variables called `RH_SUBSCRIPTION_MANAGER_USER` and `RH_SUBSCRIPTION_MANAGER_PW`. Ensure these are exported and available to Vagrant, the Vagrantfile will abort if these are not set. 
1. group_var/all.yml file filled in with all your specific settings an example is available [here](https://github.com/RedHatGov/redhatgov.workshops/blob/master/ansible_tower_aws/group_vars/all_example.yml)

## Start
Be sure to update the source_all variable in Vagrantfile of where your all.yml file is located on host system.
To start the vm just run command
```sh
vagrant up
```

## Vagrantfile for RHEL 8

Vagrantfile to spin up a RHEL 8 VM and register with RHN via subscription-manager. It will install the environment for running ansible playbooks to build the red hat ansible workshop on AWS.


## Ansible Workshop build out on AWS
```sh
ansible-playbook 1_provision.yml
```

>__NOTE:__ If 1_provision.yml playbook has errors you will need to start over after running 
>```sh
>ansible-playbook 4_unregister.yml -e NOSSH=true
>```

__NOTE:__ Might need to remove escape characters from redhatgov.workshops/ansible_tower_aws/roles/admin_server_config/tasks/main.yml regex.  2_preload.yml might hang so you can just ctrl->C and run again until it finishes.
```sh
ansible-playbook 2_preload.yml
./admin.sh  #logs you into the admin host
```
At this point, you should be on the admin host in AWS.
```sh
cd src/ansible_tower_aws
source env.sh         # enter your workshop password here, it's in the all.yml file.
ansible-playbook 3_load.yml
```
>__NOTE:__  Playbook 3_load.yml does not install pip3 for the towers so you will need to run ansible command manually then rerun the 3_load.yml playbook 
>```sh
>ansible -i inventory/hosts tower_rhel_nodes -m package -a "name=python3-pip state=latest" --private-key .redhatgov/fierce-test-key -u ec2-user -b
>```

## To test workshop
copy the test-workshop.yml file onto the admin server and run
```sh
ansible-playbook test-workshop.yml --syntax-check && ansible-playbook test-workshop.yml
```

## To remove the workshop environment from AWS
```sh
ansible-playbook 4_unregister.yml
```
> __NOTE:__ If any errors while unregistering run again with environment variable
>```sh
>ansible-playbook 4_unregister.yml -e NOSSH=true
>```

## Notes

Using the current latest versions of Vagrant and VirtualBox on MacOS, the version of VirtualBox Guest Additions is newer than the version packaged in roboxes/rhel8. Vagrant will try and update this before the VM has been registered with RHN so all calls to yum install fail. For this reason `config.vbguest.auto_update = false` is configured.
