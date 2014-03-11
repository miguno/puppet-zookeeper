class zookeeper::config inherits zookeeper {

  file { $config:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template($config_template),
    require => [ Package["zookeeper-server"] ],
  }

  if $is_standalone == false {
    file { 'zookeeper-myid':
      path    => "${data_dir}/myid",
      ensure  => file,
      owner   => $user,
      group   => $group,
      mode    => '0644',
      content => "${myid}\n",
      require => [ Package["zookeeper-server"], File[$data_dir] ],
    }
  }

}
