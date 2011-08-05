# Define: monit::check::resque_scheduler
# Creates a monit resque scheduler check,
#
# Parameters:
#   namevar     - the name of this resource will be the process name
#   group	- the monit group (optional)
#   command_uid - the UID and GID to run the resque scheduler as
#   rails_root	- the Rails project root.
#   rails_env	- the Rails environment
#
# Actions:
#   The following actions gets taken by this defined type:
#    - creates /etc/monit/conf.d/resque_scheduler_namevar.monitrc as root:root mode 0400 based on _template_
#
# Requires:
#   - Package["monit"]
#
# Sample usage:
# (start code)
#   monit::check::resque_scheduler{"preprod":
#     group		=> 'resque-scheduler-preproduction',
#     command_uid	=> 'deploy',
#     rails_root	=> '/var/www/project/current',
#     rails_env		=> 'preproduction';
#   }
# (end)

define monit::check::resque_scheduler($ensure=present,
                             $group=false,
                             $command_uid,
                             $rails_root,
                             $rails_env) {
	file {"/etc/monit/conf.d/resque_scheduler_$name.monitrc":
		ensure  => $ensure,
		owner   => "root",
		group   => "root",
		mode    => 0400,
		content => template("monit/check_resque_scheduler.monitrc.erb"),
		notify  => Service["monit"],
	}
}

