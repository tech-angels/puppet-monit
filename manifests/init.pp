# Monit class
#
# Stig Sandbeck Mathisen <ssm@fnord.no>
#
# See README for details

class monit {

	# The monit_secret is used with the fqdn of the host to make a
	# password for the monit http server.
	$monit_default_secret="This is not very secret, is it?"

	# The default alert recipient.  You can override this by setting the
	# variable "$monit_alert" in your node specification.
	$monit_default_alert="nobody@example.com"

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

	file { "/etc/monit/conf.d/template.monitrc":
	}

	# Monit is disabled by default on debian / ubuntu
	case $operatingsystem {
		"debian": {
			file { "/etc/default/monit":
				content => "startup=1\n",
			}
		}
	}

	# A definition used by other modules and classes to include monitrc
	# snippets.
	define config($ensure=present,$target="",$source="",$content="") {
		file {"/etc/monit/conf.d/$name.monitrc":
	                ensure => $ensure,
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

	# A template configuration snippet.  It would need to be included,
	# since monit's "include" statement cannot handle an empty directory.
	monit::config{ "monit_template":
		source => "puppet:///monit/template.monitrc",
	}
}
