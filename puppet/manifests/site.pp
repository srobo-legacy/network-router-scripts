file { '/etc/sr_network_setup.sh':
  content => template('sr_network_setup.sh.erb'),
  owner => 'root',
  group => 'root',
  mode => '0775',
}
