#! /bin/bash
wget https://apt.puppetlabs.com/puppet-release-bionic.deb
sudo dpkg -i puppet-release-bionic.deb
sudo apt update
sudo apt install puppetserver -y
export PATH=/opt/puppetlabs/bin:$PATH
sudo /opt/puppetlabs/bin/puppet config set dns_alt_names 'puppet,puppet.davidsdemo.com' --section main
sudo sh -c 'echo "$(hostname -i) puppet.davidsdemo.com puppet" >> /etc/hosts'
sudo sh -c 'echo "10.10.0.5 puppet-agent.davidsdemo.com puppet-agent" >> /etc/hosts'
sudo systemctl start puppet
sudo systemctl enable puppet
sudo /opt/puppetlabs/bin/puppet resource service puppetserver ensure=running
sudo /opt/puppetlabs/bin/puppet resource service puppetserver enable=true
sudo /opt/puppetlabs/bin/puppetserver ca setup

# later 
# sudo /opt/puppetlabs/bin/puppetserver ca sign --certname puppet-agent.davidsdemo.com

ssh-keygen -b 4096 -t rsa -f /home/david/.ssh/id_rsa -q -N ""

# later
# copy id_rsa into agent's .ssh/authorized_keys