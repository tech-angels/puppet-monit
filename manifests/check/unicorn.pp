# Define: monit::check::unicorn
# Creates a monit Unicorn check,
#
# Parameters:
#   namevar     - the name of this resource will be the process name
#   group	- the monit group (optional)
#   command_uid - the UID and GID to run Unicorn as
#   rails_root	- the Rails project root.
#   rails_env	- the Rails environment
#   config_file - the Unicorn config file. Default: unicorn.conf
#   pid_file    - the Unicorn pid file. Default: ${rails_root}/tmp/pids/unicorn.pid
#
# Requires:
#   - Package["monit"]
#
# Sample usage:
# (start code)
#   monit::check::unicorn{"preprod":
#     group		=> 'unicorn preprod',
#     command_uid	=> 'deploy',
#     rails_root	=> '/var/www/project/current',
#     rails_env		=> 'preproduction',
#   }
# (end)

define monit::check::unicorn($ensure=present,
                             $group=false,
                             $command_uid,
                             $rails_root,
                             $rails_env=false,
                             $config_file='unicorn.conf',
			     $pid_file=false) {
  $real_pid_file = $pid_file ? {
    false   => "${rails_root}/tmp/pids/unicorn.pid",
    default => $pid_file
  }

  file {"/etc/monit/conf.d/unicorn_$name.monitrc":
    ensure  => $ensure,
    owner   => "root",
    group   => "root",
    mode    => 0400,
    content => template("monit/check_unicorn.monitrc.erb"),
    notify  => Service["monit"],
  }
}

