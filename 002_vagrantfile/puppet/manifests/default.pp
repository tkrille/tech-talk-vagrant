class { 'apt':
  always_apt_update => true,
}

package {
  'sudo':
    ensure => latest;
  'task-german':
    ensure => latest;
  'openjdk-7-jre-headless':
    ensure => latest;
  'tomcat7':
    ensure  => latest,
    require => Package['openjdk-7-jre-headless'];
}

class { 'postgresql::globals':
  encoding => 'UTF8',
  locale   => 'en_US.UTF-8',
} -> class { 'postgresql::server':
  listen_addresses        => '*',
  ip_mask_allow_all_users => '0.0.0.0/0',
  ipv4acls                => [
    'local all all           trust',
    'host  all all 0.0.0.0/0 trust',
  ],
}

postgresql::server::db { 'ong':
  user     => 'ong',
  password => postgresql_password('ong', 'b4s3dg0d'),
}

Package <| |> {
  require +> Class["apt::update"]
}
