#!/bin/bash
# add a cron job that calls this file to remove systems when finished
# 1 14 12 * * /home/vagrant/src/redhatgov.workshops/ansible_tower_aws/unregister.sh
# Min HR DayofMonth MonthofYear DayofWeek /path/to/script
  
echo ---------------Unregister AWS Ansible Workshop Systems---------------
echo --------------------------------Start--------------------------------
source /home/vagrant/.bash_profile

cd  /home/vagrant/src/redhatgov.workshops/ansible_tower_aws
ansible-playbook 4_unregister.yml
#ansible-playbook test.yml
if [ ! $? -eq 0 ]; then
  ansible-playbook 4_unregister.yml -e NOSSH=true
  #ansible-playbook test1.yml
fi

echo --------------------------------Finish-------------------------------