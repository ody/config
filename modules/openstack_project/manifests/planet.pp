# == Class: openstack_project::planet
#
class openstack_project::planet (
  $sysadmins = []
) {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => $sysadmins,
  }
  include ::planet

  planet::site { 'openstack':
    git_url => 'https://github.com/openstack/openstack-planet.git',
  }
}
