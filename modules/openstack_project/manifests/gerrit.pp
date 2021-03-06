# == Class: openstack_project::gerrit
#
# A wrapper class around the main gerrit class that sets gerrit
# up for launchpad single sign on and bug/blueprint links

class openstack_project::gerrit (
  $vhost_name = $::fqdn,
  $canonicalweburl = "https://${::fqdn}/",
  $serveradmin = 'webmaster@openstack.org',
  $ssh_host_key = '/home/gerrit2/review_site/etc/ssh_host_rsa_key',
  $ssh_project_key = '/home/gerrit2/review_site/etc/ssh_project_rsa_key',
  $ssl_cert_file = '',
  $ssl_key_file = '',
  $ssl_chain_file = '',
  $ssl_cert_file_contents = '',
  $ssl_key_file_contents = '',
  $ssl_chain_file_contents = '',
  $ssh_dsa_key_contents = '', # If left empty puppet will not create file.
  $ssh_dsa_pubkey_contents = '', # If left empty puppet will not create file.
  $ssh_rsa_key_contents = '', # If left empty puppet will not create file.
  $ssh_rsa_pubkey_contents = '', # If left empty puppet will not create file.
  $ssh_project_rsa_key_contents = '', # If left empty will not create file.
  $ssh_project_rsa_pubkey_contents = '', # If left empty will not create file.
  $email = '',
  $database_poollimit = '',
  $container_heaplimit = '',
  $core_packedgitopenfiles = '',
  $core_packedgitlimit = '',
  $core_packedgitwindowsize = '',
  $sshd_threads = '',
  $httpd_acceptorthreads = '',
  $httpd_minthreads = '',
  $httpd_maxthreads = '',
  $httpd_maxwait = '',
  $war = '',
  $contactstore = false,
  $contactstore_appsec = '',
  $contactstore_pubkey = '',
  $contactstore_url = '',
  $script_user = 'update',
  $script_key_file = '/home/gerrit2/.ssh/id_rsa',
  $script_logging_conf = '/home/gerrit2/.sync_logging.conf',
  $projects_file = 'UNDEF',
  $github_username = '',
  $github_oauth_token = '',
  $github_project_username = '',
  $github_project_password = '',
  $mysql_password = '',
  $mysql_root_password = '',
  $trivial_rebase_role_id = '',
  $email_private_key = '',
  $replicate_github = true,
  $replicate_local = true,
  $local_git_dir = '/var/lib/git',
  $cla_description = 'OpenStack Individual Contributor License Agreement',
  $cla_file = 'static/cla.html',
  $cla_id = '2',
  $cla_name = 'ICLA',
  $testmode = false,
  $sysadmins = [],
  $swift_username = '',
  $swift_password = '',
) {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443, 29418],
    sysadmins                 => $sysadmins,
  }

  class { 'jeepyb::openstackwatch':
    projects       => [
      'openstack/ceilometer',
      'openstack/cinder',
      'openstack/glance',
      'openstack/heat',
      'openstack/horizon',
      'openstack/infra',
      'openstack/keystone',
      'openstack/nova',
      'openstack/oslo',
      'openstack/quantum',
      'openstack/swift',
      'openstack/tempest',
      'openstack-dev/devstack',
    ],
    container      => 'rss',
    feed           => 'openstackwatch.xml',
    json_url       => 'https://review.openstack.org/query?q=status:open',
    swift_username => $swift_username,
    swift_password => $swift_password,
    swift_auth_url => 'https://auth.api.rackspacecloud.com/v1.0',
    auth_version   => '1.0',
  }

  class { '::gerrit':
    vhost_name                      => $vhost_name,
    canonicalweburl                 => $canonicalweburl,
    # opinions
    enable_melody                   => true,
    melody_session                  => true,
    # passthrough
    ssl_cert_file                   => $ssl_cert_file,
    ssl_key_file                    => $ssl_key_file,
    ssl_chain_file                  => $ssl_chain_file,
    ssl_cert_file_contents          => $ssl_cert_file_contents,
    ssl_key_file_contents           => $ssl_key_file_contents,
    ssl_chain_file_contents         => $ssl_chain_file_contents,
    ssh_dsa_key_contents            => $ssh_dsa_key_contents,
    ssh_dsa_pubkey_contents         => $ssh_dsa_pubkey_contents,
    ssh_rsa_key_contents            => $ssh_rsa_key_contents,
    ssh_rsa_pubkey_contents         => $ssh_rsa_pubkey_contents,
    ssh_project_rsa_key_contents    => $ssh_project_rsa_key_contents,
    ssh_project_rsa_pubkey_contents => $ssh_project_rsa_pubkey_contents,
    email                           => $email,
    openidssourl                    => 'https://login.launchpad.net/+openid',
    database_poollimit              => $database_poollimit,
    container_heaplimit             => $container_heaplimit,
    core_packedgitopenfiles         => $core_packedgitopenfiles,
    core_packedgitlimit             => $core_packedgitlimit,
    core_packedgitwindowsize        => $core_packedgitwindowsize,
    sshd_threads                    => $sshd_threads,
    httpd_acceptorthreads           => $httpd_acceptorthreads,
    httpd_minthreads                => $httpd_minthreads,
    httpd_maxthreads                => $httpd_maxthreads,
    httpd_maxwait                   => $httpd_maxwait,
    commentlinks                    => [
      {
        name  => 'changeid',
        match => '(I[0-9a-f]{8,40})',
        link  => '#q,$1,n,z',
      },
      {
        name  => 'launchpad',
        match => '(\\b[Bb]ug|[Ll][Pp]\\b)[ \\t#:]*(\\d+)',
        link  => 'https://code.launchpad.net/bugs/$2',
      },
      {
        name  => 'blueprint',
        match => '(\\b[Bb]lue[Pp]rint|[Bb][Pp]\\b)[ \\t#:]*([A-Za-z0-9\\-]+)',
        link  => 'https://blueprints.launchpad.net/openstack/?searchtext=$2',
      },
    ],
    war                             => $war,
    contactstore                    => $contactstore,
    contactstore_appsec             => $contactstore_appsec,
    contactstore_pubkey             => $contactstore_pubkey,
    contactstore_url                => $contactstore_url,
    mysql_password                  => $mysql_password,
    mysql_root_password             => $mysql_root_password,
    email_private_key               => $email_private_key,
    replicate_github                => $replicate_github,
    replicate_local                 => $replicate_local,
    testmode                        => $testmode,
    require                         => Class[openstack_project::server],
  }
  if ($testmode == false) {
    class { 'gerrit::cron':
      script_user     => $script_user,
      script_key_file => $script_key_file,
    }
    class { 'github':
      username         => $github_username,
      project_username => $github_project_username,
      project_password => $github_project_password,
      oauth_token      => $github_oauth_token,
      require          => Class['::gerrit']
    }
  }

  file { '/home/gerrit2/review_site/static/echosign-cla.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/gerrit/echosign-cla.html',
    replace => true,
    require => Class['::gerrit'],
  }

  file { '/home/gerrit2/review_site/static/cla.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/gerrit/cla.html',
    replace => true,
    require => Class['::gerrit'],
  }

  file { '/home/gerrit2/review_site/static/usg-cla.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/gerrit/usg-cla.html',
    replace => true,
    require => Class['::gerrit'],
  }

  file { '/home/gerrit2/review_site/static/system-cla.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/gerrit/system-cla.html',
    replace => true,
    require => Class['::gerrit'],
  }

  file { '/home/gerrit2/review_site/static/title.png':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/openstack.png',
    require => Class['::gerrit'],
  }

  file { '/home/gerrit2/review_site/static/openstack-page-bkg.jpg':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/openstack-page-bkg.jpg',
    require => Class['::gerrit'],
  }

  file { '/home/gerrit2/review_site/etc/GerritSite.css':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/gerrit/GerritSite.css',
    require => Class['::gerrit'],
  }

  file { '/home/gerrit2/review_site/etc/GerritSiteHeader.html':
    ensure  => present,
    source  =>
      'puppet:///modules/openstack_project/gerrit/GerritSiteHeader.html',
    require => Class['::gerrit'],
  }

  cron { 'gerritsyncusers':
    ensure => absent,
  }

  cron { 'sync_launchpad_users':
    ensure => absent,
  }

  file { '/home/gerrit2/review_site/hooks/change-merged':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    source  => 'puppet:///modules/openstack_project/gerrit/change-merged',
    replace => true,
    require => Class['::gerrit'],
  }

  file { '/home/gerrit2/review_site/hooks/patchset-created':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    content => template('openstack_project/gerrit_patchset-created.erb'),
    replace => true,
    require => Class['::gerrit'],
  }

  if ($projects_file != 'UNDEF') {
    if ($replicate_local) {
      file { $local_git_dir:
        ensure  => directory,
        owner   => 'gerrit2',
        require => Class['::gerrit'],
      }
      cron { 'mirror_repack':
        user        => 'gerrit2',
        weekday     => '0',
        hour        => '4',
        minute      => '7',
        command     => 'find /var/lib/git/ -type d -name "*.git" -print -exec git --git-dir="{}" repack -afd \;',
        environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
      }
    }

    file { '/home/gerrit2/projects.yaml':
      ensure  => present,
      owner   => 'gerrit2',
      group   => 'gerrit2',
      mode    => '0444',
      content => template($projects_file),
      replace => true,
      require => Class['::gerrit'],
    }

    file { '/home/gerrit2/acls':
      ensure  => directory,
      owner   => 'gerrit2',
      group   => 'gerrit2',
      mode    => '0444',
      recurse => true,
      replace => true,
      source  => 'puppet:///modules/openstack_project/gerrit/acls',
      require => Class['::gerrit']
    }

    exec { 'manage_projects':
      command     => '/usr/local/bin/manage-projects',
      timeout     => 900, # 15 minutes
      subscribe   => [
          File['/home/gerrit2/projects.yaml'],
          File['/home/gerrit2/acls'],
        ],
      refreshonly => true,
      require     => [
          File['/home/gerrit2/projects.yaml'],
          File['/home/gerrit2/acls'],
          Class['jeepyb'],
        ],
    }
  }
  file { '/home/gerrit2/review_site/bin/set_agreements.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('openstack_project/gerrit_set_agreements.sh.erb'),
    replace => true,
    require => Class['::gerrit']
  }
  exec { 'set_contributor_agreements':
    path    => ['/bin', '/usr/bin'],
    command => '/home/gerrit2/review_site/bin/set_agreements.sh',
    require => File['/home/gerrit2/review_site/bin/set_agreements.sh']
  }
}
