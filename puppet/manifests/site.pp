$newbury_nic = hiera('newbury_nic')
$floor_nic = hiera('floor_nic')
$newbury_side_comp_addr = hiera('newbury_side_comp_addr')
$floor_comp_addr = hiera('floor_comp_addr')
$floor_comp_net = hiera('floor_comp_net')
$lease_range = hiera('lease_range')

file { '/etc/sr_network_setup.sh':
  content => template('sr_network_setup.sh.erb'),
  owner => 'root',
  group => 'root',
  mode => '0775',
}
