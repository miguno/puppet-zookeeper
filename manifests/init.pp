# == Class zookeeper
#
class zookeeper (
  $autopurge_purge_interval    = $zookeeper::params::autopurge_purge_interval,
  $autopurge_snap_retain_count = $zookeeper::params::autopurge_snap_retain_count,
  $client_port            = $zookeeper::params::client_port,
  $command                = $zookeeper::params::command,
  $config                 = $zookeeper::params::config,
  $config_template        = $zookeeper::params::config_template,
  $data_dir               = $zookeeper::params::data_dir,
  $group                  = $zookeeper::params::group,
  $init_limit             = $zookeeper::params::init_limit,
  $leader_election_port   = $zookeeper::params::leader_election_port,
  $max_client_connections = $zookeeper::params::max_client_connections,
  $myid                   = $zookeeper::params::myid,
  $package_name           = $zookeeper::params::package_name,
  $package_ensure         = $zookeeper::params::package_ensure,
  $package_origin         = $zookeeper::params::package_origin,
  $peer_port              = $zookeeper::params::peer_port,
  $quorum                 = $zookeeper::params::quorum,
  $service_autorestart    = hiera('zookeeper::service_autorestart', $zookeeper::params::service_autorestart),
  $service_enable         = hiera('zookeeper::service_enable', $zookeeper::params::service_enable),
  $service_ensure         = $zookeeper::params::service_ensure,
  $service_manage         = hiera('zookeeper::service_manage', $zookeeper::params::service_manage),
  $service_name           = $zookeeper::params::service_name,
  $service_retries        = $zookeeper::params::service_retries,
  $service_startsecs      = $zookeeper::params::service_startsecs,
  $service_stderr_logfile_keep    = $zookeeper::params::service_stderr_logfile_keep,
  $service_stderr_logfile_maxsize = $zookeeper::params::service_stderr_logfile_maxsize,
  $service_stdout_logfile_keep    = $zookeeper::params::service_stdout_logfile_keep,
  $service_stdout_logfile_maxsize = $zookeeper::params::service_stdout_logfile_maxsize,
  $service_stopasgroup    = hiera('zookeeper::service_stopasgroup', $zookeeper::params::service_stopasgroup),
  $service_stopsignal     = $zookeeper::params::service_stopsignal,
  $sync_limit             = $zookeeper::params::sync_limit,
  $tick_time              = $zookeeper::params::tick_time,
  $user                   = $zookeeper::params::user,
  $zookeeper_start_binary = $zookeeper::params::zookeeper_start_binary,
) inherits zookeeper::params {

  if !is_integer($autopurge_purge_interval) {
    fail('The $autopurge_purge_interval parameter must be an integer number')
  }
  if !is_integer($autopurge_snap_retain_count) {
    fail('The $autopurge_snap_retain_count parameter must be an integer number')
  }
  if !is_integer($client_port) { fail('The $client_port parameter must be an integer number') }
  validate_string($command)
  validate_absolute_path($config)
  validate_string($config_template)
  validate_absolute_path($data_dir)
  validate_string($group)
  if !is_integer($init_limit) { fail('The $init_limit parameter must be an integer number') }
  if !is_integer($leader_election_port) { fail('The $leader_election_port parameter must be an integer number') }
  if !is_integer($max_client_connections) { fail('The $max_client_connections parameter must be an integer number') }
  if !is_integer($myid) { fail('The $myid parameter must be an integer number') }
  validate_string($package_name)
  validate_string($package_ensure)
  if !is_integer($peer_port) { fail('The $peer_port parameter must be an integer number') }
  validate_array($quorum)
  validate_bool($service_autorestart)
  validate_bool($service_enable)
  validate_string($service_ensure)
  validate_bool($service_manage)
  validate_string($service_name)
  if !is_integer($service_retries) { fail('The $service_retries parameter must be an integer number') }
  if !is_integer($service_startsecs) { fail('The $service_startsecs parameter must be an integer number') }
  if !is_integer($service_stderr_logfile_keep) {
    fail('The $service_stderr_logfile_keep parameter must be an integer number')
  }
  validate_string($service_stderr_logfile_maxsize)
  if !is_integer($service_stdout_logfile_keep) {
    fail('The $service_stdout_logfile_keep parameter must be an integer number')
  }
  validate_string($service_stdout_logfile_maxsize)
  validate_bool($service_stopasgroup)
  validate_string($service_stopsignal)
  if !is_integer($sync_limit) { fail('The $sync_limit parameter must be an integer number') }
  if !is_integer($tick_time) { fail('The $tick_time parameter must be an integer number') }
  validate_string($user)
  validate_absolute_path($zookeeper_start_binary)

  $is_standalone = empty($quorum)

  include '::zookeeper::install'
  include '::zookeeper::config'
  include '::zookeeper::service'

  # Anchor this as per #8040 - this ensures that classes won't float off and
  # mess everything up. You can read about this at:
  # http://docs.puppetlabs.com/puppet/2.7/reference/lang_containment.html#known-issues
  anchor { 'zookeeper::begin': }
  anchor { 'zookeeper::end': }

  Anchor['zookeeper::begin'] -> Class['::zookeeper::install'] -> Class['::zookeeper::config']
    ~> Class['::zookeeper::service'] -> Anchor['zookeeper::end']
}
