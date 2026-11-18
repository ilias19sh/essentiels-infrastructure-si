class web_nginx {
  package { 'nginx':
    ensure => installed,
  }

  file { '/var/www/html/puppet.html':
    ensure  => file,
    content => "Configuration geree avec Puppet\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['nginx'],
  }

  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => Package['nginx'],
  }
}
