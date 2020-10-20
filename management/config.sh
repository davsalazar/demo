wget https://apt.puppetlabs.com/puppet-release-bionic.deb
sudo dpkg -i puppet-release-bionic.deb
sudo apt update
sudo apt install puppetserver
export PATH=/opt/puppetlabs/bin:$PATH
sudo /opt/puppetlabs/bin/puppet config set dns_alt_names 'puppet' --section main

# set private ip address to puppet in /etc/hosts