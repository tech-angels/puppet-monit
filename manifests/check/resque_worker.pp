# Define: monit::check::resque_worker
# Creates a monit resque worker check,
#
# Parameters:
#   namevar           - the name of this resource will be the process name
#   num_workers       - number of workers
#   group	      - the monit group (optional)
#   command_uid       - the UID and GID to run the resque worker as
#   rails_root	      - the Rails project root.
#   rails_env	      - the Rails environment
#   max_memory        - Max memory in Mb. Default: 300
#   max_memory_cycles - Number of consecutive cycles above max_memory for a restart. Default: 10
#   queues	      - an array of queues to run. Example: ['urgent', 'high', 'normal']
#
# Actions:
#   The following actions gets taken by this defined type:
#    - creates /etc/monit/conf.d/resque_worker_namevar.monitrc as root:root mode 0400 based on _template_
#
# Requires:
#   - Package["monit"]
#
# Sample usage:
# (start code)
#   monit::check::resque_worker{"preprod":
#     num_workers	=> 8,
#     group		=> 'resque preprod',
#     command_uid	=> 'deploy',
#     rails_root	=> '/var/www/project/current',
#     rails_env		=> 'preproduction',
#     queues		=> ['urgent', 'high', 'normal', 'mailer', 'low', 'maintenance']
#   }
# (end)

define monit::check::resque_worker($ensure=present,
                             $num_workers=1,
                             $group=false,
                             $command_uid,
                             $rails_root,
                             $rails_env,
                             $max_memory='300',
                             $max_memory_cycles='10',
                             $queues) {
	file {"/etc/monit/conf.d/resque_worker_$name.monitrc":
		ensure  => $ensure,
		owner   => "root",
		group   => "root",
		mode    => 0400,
		content => template("monit/check_resque_worker.monitrc.erb"),
		notify  => Service["monit"],
	}
}

