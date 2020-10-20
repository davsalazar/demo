#! /bin/bash
wget https://apt.puppetlabs.com/puppet-release-bionic.deb
dpkg -i puppet-release-bionic.deb
apt update
apt install puppet-agent -y
sudo sh -c 'echo "$(hostname -i) puppet-agent.davidsdemo.com puppet-agent" >> /etc/hosts'
sudo sh -c 'echo "10.10.0.4 puppet.davidsdemo.com puppet" >> /etc/hosts'
/opt/puppetlabs/bin/puppet config set server 'puppet.davidsdemo.com' --section main
/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
/opt/puppetlabs/bin/puppet agent -t
