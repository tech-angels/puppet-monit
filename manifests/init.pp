# Module: monit
#
# A puppet module to configure the monit service, and add definitions to be
# used from other classes and modules.
#
# Stig Sandbeck Mathisen <ssm@fnord.no>
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
