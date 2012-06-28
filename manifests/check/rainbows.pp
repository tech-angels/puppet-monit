# Define: monit::check::rainbows
# Creates a monit Rainbows check for a rails application,
#
# Parameters:
#   namevar     - the name of this resource will be the process name
#   group	- the monit group (optional)
#   command_uid - the UID and GID to run Rainbows as
#   rails_root	- the Rails project root.
#   rails_env	- the Rails environment
#   rvm_ruby    - the ruby version to use
#   config_file - the Rainbows config file. Default: rainbows.conf
#   pid_file    - the Rainbows pid file. Default: ${rails_root}/tmp/pids/rainbows.pid
#
# Requires:
#   - Package["monit"]
#
# Sample usage:
# (start code)
#   monit::check::rainbows{"preprod":
#     group		=> 'rainbows preprod',
#     command_uid	=> 'deploy',
#     rvm_ruby          => 'ruby-1.9.3-p0',
#     rails_root	=> '/var/www/project/current',
#     rails_env		=> 'preproduction',
#   }
# (end)

define monit::check::rainbows(
  $ensure=present,
  $group=false,
  $command_uid,
  $rails_root,
  $rails_env,
  $rvm_ruby,
  $config_file='rainbows.conf',
  $pid_file=false) {
  $real_pid_file = $pid_file ? {
    false   => "${rails_root}/tmp/pids/rainbows.pid",
    default => $pid_file
  }

  file {"/etc/monit/conf.d/rainbows_$name.monitrc":
    ensure  => $ensure,
    owner   => "root",
    group   => "root",
    mode    => 0400,
    content => template("monit/check_rainbows.monitrc.erb"),
    notify  => Service["monit"],
  }
}

