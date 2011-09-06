# Module: monit
#
# A puppet module to configure the monit service, and add definitions to be
# used from other classes and modules.
#
# Stig Sandbeck Mathisen <ssm@fnord.no>
# Micah Anderson micah@riseup.net
#
# To set any of the following, simply set them as variables in your manifests
# before the class is included, for example:
#
# $monit_enable_httpd = yes
# $monit_httpd_port = 8888
# $monit_secret="something secret, something safe"
# $monit_alert="someone@example.org"
# $monit_from="monit@example.org"
# $monit_mailserver="mail.example.org"
# $monit_pool_interval="120"
# 
# include monit
#
# The following is a list of the currently available variables:
#
# monit_alert:                who should get the email notifications?
#                             Default: root@localhost
#
# monit_from:                 what should be the sender email address
#                             of email notifications?
#                             Default: monit@fqdn
#
# monit_enable_httpd:         should the httpd daemon be enabled?
#                             set this to 'yes' to enable it, be sure
#                             you have set the $monit_default_secret
#                             Valid values: yes or no
#                             Default: no
#
# monit_httpd_port:           what port should the httpd run on?
#                             Default: 2812
#
#
# monit_mailserver:           where should monit be sending mail?
#                             set this to the mailserver
#                             Default: localhost
#
# monit_pool_interval:        how often (in seconds) should monit poll?
#                             Default: 120
#

class monit {


	# The monit_secret is used with the fqdn of the host to make a
	# password for the monit http server.
	$monit_default_secret="This is not very secret, is it?"

	# The default alert recipient.  You can override this by setting the
	# variable "$monit_alert" in your node specification.
	$monit_default_alert="root@localhost"

        $monit_default_from="monit@${fqdn}"

        # How often should the daemon pool? Interval in seconds.
        case $monit_pool_interval {
          '': { $monit_pool_interval = '120' }
        }

        # Should the httpd daemon be enabled, or not? By default it is not
        case $monit_enable_httpd {
          '': { $monit_enable_httpd = 'no' }
        }
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
                        source  => "puppet:///monit/empty/",
                        recurse => true,
                        purge   => true,
                        force   => true,
                        ignore  => '.ignore';
	}

	# The main configuration file
	file { "/etc/monit/monitrc":
		content => template("monit/monitrc.erb"),
	}

	# Monit is disabled by default on debian / ubuntu
	case $operatingsystem {
		"debian": {
			file { "/etc/default/monit":
				content => "startup=1\nCHECK_INTERVALS=${monit_pool_interval}\n",
				before  => Service["monit"]
			}
		}
	}

	# A template configuration snippet.  It would need to be included,
	# since monit's "include" statement cannot handle an empty directory.
	monit::snippet{ "monit_template":
		source => "puppet://$server/modules/monit/template.monitrc",
	}
}
