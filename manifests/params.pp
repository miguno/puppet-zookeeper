class zookeeper::params {
  $autopurge_purge_interval    = 24
  $autopurge_snap_retain_count = 5
  $client_port            = 2181
  $zookeeper_start_binary = '/usr/bin/zookeeper-server' # managed by zookeeper-server RPM, do not change unless you
                                                        # are certain that your RPM uses a different path
  # Because $command relies on the $zookeeper_start_binary variable, it must be defined AFTER $zookeeper_start_binary.
  $command                = "$zookeeper_start_binary start-foreground"
  $config                 = '/etc/zookeeper/conf/zoo.cfg' # managed by zookeeper-server RPM, do not change unless you
                                                          # are certain that your RPM uses a different path
  $config_template        = 'zookeeper/zoo.cfg.erb'
  $data_dir               = '/var/lib/zookeeper'
  $group                  = 'zookeeper' # managed by zookeeper-server RPM, do not change unless you are certain that
                                        # your RPM uses a different group
  $init_limit             = 10
  $leader_election_port   = 3888
  $max_client_connections = 50
  $myid                   = 1
  $package_name           = 'zookeeper-server'
  $package_ensure         = 'latest'
  $peer_port              = 2888
  $quorum                 = [] # If you want to use a quorum (normally 3 or 5 members), set this variable to e.g.
                               # ['server.1=zookeeper1:2888:3888', 'server.2=zookeeper2:2888:3888', ...] where
                               # server.<X> corresponds to a machine's 'zookeeper::myid'.
  $service_autorestart    = true
  $service_enable         = true
  $service_ensure         = 'present'
  $service_manage         = true
  $service_name           = 'zookeeper'
  $service_retries        = 999
  $service_startsecs      = 10
  $service_stderr_logfile_keep    = 10
  $service_stderr_logfile_maxsize = '20MB'
  $service_stdout_logfile_keep    = 5
  $service_stdout_logfile_maxsize = '20MB'
  $service_stopasgroup    = true
  $service_stopsignal     = 'KILL'
  $sync_limit             = 5
  $tick_time              = 2000
  $user                   = 'zookeeper' # managed by zookeeper-server RPM, do not change unless you are certain that
                                        # your RPM uses a different user
}
