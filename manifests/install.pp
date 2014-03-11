class zookeeper::install inherits zookeeper {

  package { 'zookeeper-server':
    ensure  => $package_ensure,
    name    => $package_name,
  }

  file { $data_dir:
    ensure       => directory,
    owner        => $user,
    group        => $group,
    mode         => '0755',
    recurse      => true,
    recurselimit => 0,
    # Require is needed because the zookeeper-server package manages the user
    require      => Package['zookeeper-server'],
  }

}
