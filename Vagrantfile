Vagrant.require_version ">= 2.1.0" # 2.1.0 minimum required for triggers

user = ENV['RH_SUBSCRIPTION_MANAGER_USER']
password = ENV['RH_SUBSCRIPTION_MANAGER_PW']
source_all = '~/Downloads/ansible-tower-aws-group_vars-all.yml'
unreg_script = './unregister.sh'

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
  git clone https://github.com/RedHatGov/redhatgov.workshops.git
  cd ~/src/redhatgov.workshops/ansible_tower_aws/
  cp ~/all.yml group_vars/all.yml
  echo 'cd /home/vagrant/src/redhatgov.workshops/ansible_tower_aws/' >> ~/.bash_profile
  echo 'virtualenv --system-site-packages ansible' >> ~/.bash_profile
  echo 'source ansible/bin/activate' >> ~/.bash_profile
  echo 'pip install boto boto3' >> ~/.bash_profile
  echo "export AWS_ACCESS_KEY_ID=$(grep aws_access_key ~/all.yml | awk -F'\"' '{print $2}')" >> ~/.bash_profile
  echo "export AWS_SECRET_ACCESS_KEY=$(grep aws_secret_key ~/all.yml | awk -F'\"' '{print $2}')" >> ~/.bash_profile
}

unregister_script = %{
if subscription-manager status; then
  sudo subscription-manager unregister
fi
}
workshop_remove_script = %{
cd ~/src/redhatgov.workshops/ansible_tower_aws
./unregister.sh
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
  
  config.vm.provision "file", source: "#{source_all}", destination: "~/all.yml"
  config.vm.provision "shell", inline: register_script
  config.vm.provision "shell", inline: container_dev_script
  config.vm.provision "shell", inline: raytheon_ansible_workshop, privileged: false
  config.vm.provision "file", source: "#{unreg_script}", destination: "~/src/redhatgov.workshops/ansible_tower_aws/unregister.sh"

  config.trigger.before :destroy do |trigger|
    trigger.name = "Before Destroy trigger"
    trigger.info = "Unregistering this VM from RedHat Subscription Manager..."
    trigger.warn = "If this fails, unregister VMs manually at https://access.redhat.com/management/subscriptions"
    trigger.run_remote = {inline: unregister_script}
    trigger.run_remote = {inline: workshop_remove_script, privileged: false}
    trigger.on_error = :continue
  end # trigger.before :destroy
end # vagrant configure
