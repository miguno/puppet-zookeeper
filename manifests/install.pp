class zookeeper::install inherits zookeeper {

  package { 'zookeeper-server':
    ensure  => $package_ensure,
    name    => $package_name,
  }

}
