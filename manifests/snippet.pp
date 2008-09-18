# Define: monit::snippet
# Creates a monit configuration snippet in /etc/monit/conf.d/
#
# Parameters:
#   namevar - the name of this resource will be used for the configuration file name
#   ensure  - present or absent
#   content - as for the "file" type
#   source  - as for the "file" type
#   target  - as for the "file' type
#
# Requires:
#   Package["monit"]
#
#
# Sample usage:
# (start code)
#   monit::check::process{"openssh":
#     pidfile     => "/var/run/sshd.pid",
#     start       => "/etc/init.d/ssh start",
#     stop        => "/etc/init.d/ssh stop",
#     customlines => ["if failed port 22 then restart"]
#   }
# (end)
define monit::snippet($ensure=present,$target="",$source="",$content="") {
	file {"/etc/monit/conf.d/$name.monitrc":
                ensure => $ensure,
		owner   => "root",
		group   => "root",
		mode    => 0400,
		notify  => Service["monit"],
                content => $content ? {
                        ""      => undef,
                        default => $content
                },
                source => $source ? {
                        ""      => undef,
                        default => $source
                },
                target => $target ? {
                        ""      => undef,
                        default => $target
                },
        }
}
