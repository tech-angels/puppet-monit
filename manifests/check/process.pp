# Define: monit::check::process
# Creates a monit process check,
#
# Parameters:
#   namevar     - the name of this resource will be the process name
#   pidfile     - the pidfile monit will check
#   start       - the command used by monit to start the service
#   stop        - the command used by monit to stop the service
#   customlines - lets you inject custom lines into the monitrc snippet, just pass an array, and it will appear in the configuration file
#
# Actions:
#   The following actions gets taken by this defined type:
#    - creates /etc/monit/conf.d/namevar.monitrc as root:root mode 0400 based on _template_
#
# Requires:
#   - Package["monit"]
#
# Sample usage:
# (start code)
#   monit::check::process{"openssh":
#     pidfile     => "/var/run/sshd.pid",
#     start       => "/etc/init.d/ssh start",
#     stop        => "/etc/init.d/ssh stop",
#     customlines => ["if failed port 22 then restart",
#                     "if 2 restarts within 3 cycles then timeout"]
#   }
# (end)

define monit::check::process($ensure=present, $process=$name,
                             $pidfile="/var/run/$name.pid",
                             $start="/etc/init.d/$name start",
                             $stop="/etc/init.d/$name stop",
                             $customlines="") {
	file {"/etc/monit/conf.d/$name.monitrc":
		ensure  => $ensure,
		owner   => "root",
		group   => "root",
		mode    => 0400,
		content => template("monit/check_process.monitrc.erb"),
		notify  => Service["monit"],
	}
}

