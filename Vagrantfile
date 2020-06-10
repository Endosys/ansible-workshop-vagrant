Vagrant.require_version ">= 2.1.0" # 2.1.0 minimum required for triggers

user = ENV['RH_SUBSCRIPTION_MANAGER_USER']
password = ENV['RH_SUBSCRIPTION_MANAGER_PW']

if !user or !password
  puts 'Required environment variables not found. Please set RH_SUBSCRIPTION_MANAGER_USER and RH_SUBSCRIPTION_MANAGER_PW'
  abort
end

register_script = %{
if ! subscription-manager status; then
  sudo subscription-manager register --username=#{user} --password=#{password} --auto-attach
  sudo subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms --enable=codeready-builder-for-rhel-8-x86_64-rpms
fi
}

container_dev_script = %{
  if ! sudo dnf list installed code; then
    sudo tee /etc/yum.repos.d/vscode.repo << ADDREPO
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
ADDREPO
  fi
  sudo dnf -y install git-core podman buildah skopeo code rsync tree
}

raytheon_ansible_workshop = %{
  sudo dnf install -y git python3-virtualenv ansible
  mkdir src
  cd src/
  #virtualenv --system-site-packages ansible
  #source ansible/bin/activate
  #pip install boto boto3
  #sudo dnf -y install git python3-boto3 ansible
  git clone https://github.com/RedHatGov/redhatgov.workshops.git
  cd ~/src/redhatgov.workshops/ansible_tower_aws/
  export AWS_ACCESS_KEY_ID=$(grep aws_access_key ~/all.yml | awk -F'"' '{print $2}')
  export AWS_SECRET_ACCESS_KEY=$(grep aws_secret_key ~/all.yml | awk -F'"' '{print $2}')
  #sed -i 's/env python/env python3/' inventory/hosts
  cp env.sh_example env.sh
  sed -i "s/AWS_ACCESS_KEY_ID.*/AWS_ACCESS_KEY_ID=\'$AWS_ACCESS_KEY_ID\'/" env.sh
  sed -i "s/AWS_SECRET_ACCESS_KEY.*/AWS_SECRET_ACCESS_KEY=\'$AWS_SECRET_ACCESS_KEY\'/" env.sh
  cp ~/all.yml group_vars/all.yml
  echo 'source ~/src/redhatgov.workshops/ansible_tower_aws/env.sh' >> ~/.bash_profile
  echo 'cd ~/src/redhatgov.workshops/ansible_tower_aws/' >> ~/.bash_profile
  echo 'virtualenv --system-site-packages ansible' >> ~/.bash_profile
  echo 'source ansible/bin/activate' >> ~/.bash_profile
  echo 'pip install boto boto3' >> ~/.bash_profile
}

# raytheon_ansible_workshop1 = %{
#   export AWS_ACCESS_KEY_ID=$(grep aws_access_key /home/vagrant/all.yml | awk -F'"' '{print $2}')
#   export AWS_SECRET_ACCESS_KEY=$(grep aws_secret_key /home/vagrant/all.yml | awk -F'"' '{print $2}')
#   sudo dnf -y install git python3-boto3 ansible
#   git clone https://github.com/RedHatGov/redhatgov.workshops.git
#   cd /home/vagrant/redhatgov.workshops/ansible_tower_aws/
#   sed -i 's/env python/env python3/' inventory/hosts
#   cp env.sh_example env.sh
#   sed -i "s/AWS_ACCESS_KEY_ID.*/AWS_ACCESS_KEY_ID=\'$AWS_ACCESS_KEY_ID\'/" env.sh
#   sed -i "s/AWS_SECRET_ACCESS_KEY.*/AWS_SECRET_ACCESS_KEY=\'$AWS_SECRET_ACCESS_KEY\'/" env.sh
#   cp /home/vagrant/all.yml group_vars/all.yml
#   echo 'source /home/vagrant/redhatgov.workshops/ansible_tower_aws/env.sh' >> /home/vagrant/.bash_profile
#   echo 'cd /home/vagrant/redhatgov.workshops/ansible_tower_aws/' >> /home/vagrant/.bash_profile
# }

unregister_script = %{
if subscription-manager status; then
  sudo subscription-manager unregister
fi
cd /home/vagrant/src/redhatgov.workshops/ansible_tower_aws
virtualenv --system-site-packages ansible
source ansible/bin/activate
pip install boto boto3
ansible-playbook 4_unregister.yml || ansible-playbook 4_unregister.yml -e NOSSH=true
rm -rf .redhatgov
}

Vagrant.configure("2") do |config|
  config.vm.box = "generic/rhel8"
#  config.vm.box_version = "1.9.28"
  # Disable guest additions check, because at this point the VM 
  # will not be registered with RHEL via subsctiption-manager 
  # and yum install <anything> will not work.
  config.vbguest.auto_update = false

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    vb.memory = "1024"
  end # virtualbox provider
  
  config.vm.provision "file", source: "~/Downloads/ansible-tower-aws-group_vars-all.yml", destination: "~/all.yml"
  config.vm.provision "shell", inline: register_script
  config.vm.provision "shell", inline: container_dev_script
  config.vm.provision "shell", inline: raytheon_ansible_workshop, privileged: false

  config.trigger.before :destroy do |trigger|
    trigger.name = "Before Destroy trigger"
    trigger.info = "Unregistering this VM from RedHat Subscription Manager..."
    trigger.warn = "If this fails, unregister VMs manually at https://access.redhat.com/management/subscriptions"
    trigger.run_remote = {inline: unregister_script}
    trigger.on_error = :continue
  end # trigger.before :destroy
end # vagrant configure
