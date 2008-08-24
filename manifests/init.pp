# Monit class
#
# Stig Sandbeck Mathisen <ssm@fnord.no>
#
# See README for details

# Module: monit
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

# Module: monit
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

# Class monit
#
#  - Installs Package["monit"]
#  - Looks after Service["monit"]
#  - Installs a default configuration
#  - Activates monit on debian/ubuntu, by replacing /etc/default/monit
#  - Creates a directory /etc/monit/conf.d where other packages can drop configuration snippets.  See monit::snippet and monit::check::process
#
class monit {


	# The monit_secret is used with the fqdn of the host to make a
	# password for the monit http server.
	$monit_default_secret="This is not very secret, is it?"

	# The default alert recipient.  You can override this by setting the
	# variable "$monit_alert" in your node specification.
	$monit_default_alert="root@localhost"

	# The package
	package { "monit":
		ensure => installed,
	}
	
	# The service
	service { "monit":
		ensure  => running,
		require => Package["monit"],
	}
	
	# How to tell monit to reload its configuration
	exec { "monit reload":
		command     => "/usr/sbin/monit reload",
		refreshonly => true,
	}
	
	# Default values for all file resources
	File {
		owner   => "root",
		group   => "root",
		mode    => 0400,
		notify  => Exec["monit reload"],
		require => Package["monit"],
	}
	
	# The main configuration directory, this should have been provided by
	# the "monit" package, but we include it just to be sure.
	file { "/etc/monit":
			ensure  => directory,
			mode    => 0700,
	}

	# The configuration snippet directory.  Other packages can put
	# *.monitrc files into this directory, and monit will include them.
	file { "/etc/monit/conf.d":
			ensure  => directory,
			mode    => 0700,
	}

	# The main configuration file
	file { "/etc/monit/monitrc":
		content => template("monit/monitrc.erb"),
	}

	# Monit is disabled by default on debian / ubuntu
	case $operatingsystem {
		"debian": {
			file { "/etc/default/monit":
				content => "startup=1\n",
				before  => Service["monit"]
			}
		}
	}

	# A template configuration snippet.  It would need to be included,
	# since monit's "include" statement cannot handle an empty directory.
	monit::snippet{ "monit_template":
		source => "puppet:///monit/template.monitrc",
	}
}
