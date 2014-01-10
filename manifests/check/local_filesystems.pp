# Define: monit::check::local_filesystems
# Creates monit filesystem checks for each local filesystem,
#
# Parameters:
#   space_usage - the maximum used space before an alert
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
#   monit::check::local_filesystems{"local":
#     space_usage => '80%';
#   }
# (end)

class monit::check::local_filesystems(
  $filesystem_select_regex='.*',
  $filesystem_reject_regex='(?=a)b', # Don't reject anything by default
  $ensure=present,
  $space_usage='90%',
  $customlines=""
) {
	file {"/etc/monit/conf.d/$name.monitrc":
		ensure  => $ensure,
		owner   => "root",
		group   => "root",
		mode    => 0400,
		content => template("monit/check_local_filesystems.monitrc.erb"),
		notify  => Service["monit"],
	}
}

