class apache {
  package { 'apache':
    name    => 'apache2',
    ensure  => present,
  }

  file { 'configuration-file':
    path    => '/etc/apache2/apache2.conf',
    ensure  => file,
    source  => 'puppet:///modules/apache/apache2.conf',
    notify  => Service['apache-service'],
  }

  service { 'apache-service':
    name          => 'apache2',
    hasrestart    => true,
  }
}

