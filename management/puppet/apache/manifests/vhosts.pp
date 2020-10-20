class apache::vhosts {
    file { '/etc/apache2/sites-available/puppet-agent.davidsdemo.com.conf':
      ensure  => file,
      content  => 'puppet:///modules/apache/httpd.conf',
    }
    file { "/var/www/puppet-agent.davidsdemo.com":
      ensure    => directory,
    }
    file { "/var/www/puppet-agent.davidsdemo.com/public_html":
      ensure    => directory,
    }
    file { "/var/www/puppet-agent.davidsdemo.com/logs":
      ensure    => directory,
    }
}
