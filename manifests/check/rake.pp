# Define: monit::check::rake
# Creates a monit rake process check,
#
# Parameters:
#   namevar     - the name of this resource will be the process name
#   group	- the monit group (optional)
#   command_uid - the UID and GID to run the rake process as
#   rails_root	- the Rails project root.
#   rails_env	- the Rails environment
#   target	- rake target
#
# Actions:
#   The following actions gets taken by this defined type:
#    - creates /etc/monit/conf.d/rake_namevar.monitrc as root:root mode 0400 based on _template_
#
# Requires:
#   - Package["monit"]
#
# Sample usage:
# (start code)
#   monit::check::rake{"preprod":
#     group		=> 'rake-my-processes',
#     command_uid	=> 'deploy',
#     rails_root	=> '/var/www/project/current',
#     rails_env		=> 'preproduction',
#     target		=> 'do:stuff'
#   }
# (end)

define monit::check::rake($ensure=present,
                             $group=false,
                             $command_uid,
                             $rails_root,
                             $rails_env,
                             $target) {
	file {"/etc/monit/conf.d/rake_$name.monitrc":
		ensure  => $ensure,
		owner   => "root",
		group   => "root",
		mode    => 0400,
		content => template("monit/check_rake.monitrc.erb"),
		notify  => Service["monit"],
	}
}

