# == Class zookeeper::wrapper
#
# === Parameters
#
# TODO: Document each class parameter.
#
# [*config_map*]
#   Use this parameter for all other ZooKeeper related config options except those that are already exposed as class
#   parameters (e.g. `$data_dir`, `$data_log_dir`, `$client_port`, `$myid`, `$quorum`).
#
class zookeeper::wrapper (
  $client_port                    = $zookeeper::params::client_port,
  $command                        = $zookeeper::params::command,
  $config                         = $zookeeper::params::config,
  $config_map                     = $zookeeper::params::config_map,
  $config_template                = $zookeeper::params::config_template,
  $data_dir                       = $zookeeper::params::data_dir,
  $data_log_dir                   = $zookeeper::params::data_log_dir,
  $group                          = $zookeeper::params::group,
  $myid                           = $zookeeper::params::myid,
  $package_name                   = $zookeeper::params::package_name,
  $package_ensure                 = $zookeeper::params::package_ensure,
  $quorum                 	  = $zookeeper::params::quorum,
  $service_autorestart            = hiera('zookeeper::service_autorestart', $zookeeper::params::service_autorestart),
  $service_enable                 = hiera('zookeeper::service_enable', $zookeeper::params::service_enable),
  $service_ensure                 = $zookeeper::params::service_ensure,
  $service_manage                 = hiera('zookeeper::service_manage', $zookeeper::params::service_manage),
  $service_name                   = $zookeeper::params::service_name,
  $service_retries                = $zookeeper::params::service_retries,
  $service_startsecs              = $zookeeper::params::service_startsecs,
  $service_stderr_logfile_keep    = $zookeeper::params::service_stderr_logfile_keep,
  $service_stderr_logfile_maxsize = $zookeeper::params::service_stderr_logfile_maxsize,
  $service_stdout_logfile_keep    = $zookeeper::params::service_stdout_logfile_keep,
  $service_stdout_logfile_maxsize = $zookeeper::params::service_stdout_logfile_maxsize,
  $service_stopasgroup            = hiera('zookeeper::service_stopasgroup', $zookeeper::params::service_stopasgroup),
  $service_stopsignal             = $zookeeper::params::service_stopsignal,
  $user                           = $zookeeper::params::user,
  $zookeeper_start_binary         = $zookeeper::params::zookeeper_start_binary,
) inherits zookeeper::params {

class { 'zookeeper':
  client_port                    => $client_port,
  command                        => $command,
  config                         => $config,
  config_map                     => $config_map,
  config_template                => $config_template,
  data_dir                       => $data_dir,
  data_log_dir                   => $data_log_dir,
  group                          => $group,
  myid                           => $myid,
  package_name                   => $package_name,
  package_ensure                 => $package_ensure,
  quorum                         => $quorum,
  service_autorestart            => $service_autorestart,
  service_enable                 => $service_enable,
  service_ensure                 => $service_ensure,
  service_manage                 => $service_manage,
  service_name                   => $service_name,
  service_retries                => $service_retries,
  service_startsecs              => $service_startsecs,
  service_stderr_logfile_keep    => $service_stderr_logfile_keep,
  service_stderr_logfile_maxsize => $service_stderr_logfile_maxsize,
  service_stdout_logfile_keep    => $service_stdout_logfile_keep,
  service_stdout_logfile_maxsize => $service_stdout_logfile_maxsize,
  service_stopasgroup            => $service_stopasgroup,
  service_stopsignal             => $service_stopsignal,
  user                           => $user,
  zookeeper_start_binary         => $zookeeper_start_binary,
}
  if !($service_ensure in ['present', 'absent']) {
    fail('service_ensure parameter must be "present" or "absent"')
  }

  if $service_manage == true {

    supervisor::service {
      $service_name:
        ensure                 => $service_ensure,
        enable                 => $service_enable,
        command                => $command,
        directory              => '/',
        user                   => $user,
        group                  => $group,
        autorestart            => $service_autorestart,
        startsecs              => $service_startsecs,
        retries                => $service_retries,
        stopsignal             => $service_stopsignal,
        stopasgroup            => $service_stopasgroup,
        stdout_logfile_maxsize => $service_stdout_logfile_maxsize,
        stdout_logfile_keep    => $service_stdout_logfile_keep,
        stderr_logfile_maxsize => $service_stderr_logfile_maxsize,
        stderr_logfile_keep    => $service_stderr_logfile_keep,
        require                => [ Class['zookeeper::config'], Class['::supervisor'] ],
    }

    # Make sure that the init.d script shipped with zookeeper-server is not registered as a system service and that the
    # service itself is not running in any case (because we want to run ZooKeeper via supervisord).
    service { $package_name:
      ensure => 'stopped',
      enable => false,
    }

    $subscribe_real = $is_standalone ? {
      true  => File[$config],
      false => [ File[$config], File['zookeeper-myid'] ],
    }

    if $service_enable == true {
      exec { 'restart-zookeeper':
        command     => "supervisorctl restart ${service_name}",
        path        => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'],
        user        => 'root',
        refreshonly => true,
        subscribe   => $subscribe_real,
        onlyif      => 'which supervisorctl &>/dev/null',
        require     => [ Class['zookeeper::config'], Class['::supervisor'] ],
      }
    }
  }
}
