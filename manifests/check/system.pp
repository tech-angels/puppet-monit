# Define: monit::check::system
# Creates a monit system check,
#
# Parameters:
#   namevar     - the name of this resource will be the system name
#   loadavg_1   - the limit to load average over 1 minute before alert
#   loadavg_5   - the limit to load average over 5 minute before alert
#   memory_usage - the limit to memory usage before alert
#   swap_usage   - the limit to swap usage before alert
#   cpu_usage_user - the limit to user cpu usage before alert
#   cpu_usage_system - the limit to system cpu usage before alert
#   cpu_usage_wait - the limit to wait cpu usage before alert
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
#   monit::check::system{
#     $hostname:
#       memory_usage	=> '90%';
#   }
# (end)

define monit::check::system($ensure=present,
                            $loadavg_1=false,
                            $loadavg_5=false,
                            $memory_usage=false,
                            $swap_usage=false,
                            $cpu_usage_user=false,
                            $cpu_usage_system=false,
                            $cpu_usage_wait=false,
                            $customlines="") {
	file {"/etc/monit/conf.d/$name.monitrc":
		ensure  => $ensure,
		owner   => "root",
		group   => "root",
		mode    => 0400,
		content => template("monit/check_system.monitrc.erb"),
		notify  => Service["monit"],
	}
}

