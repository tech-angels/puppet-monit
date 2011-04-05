# Define: monit::check::filesystem
# Creates a monit filesystem check,
#
# Parameters:
#   namevar     - the name of this resource will be the process name
#   fspath      - the filesystem path
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
#   monit::check::filesystem{"rootfs":
#     path	=> '/dev/hda1',
#     space_usage	=> '20%';
#   }
# (end)

define monit::check::filesystem($ensure=present,
                             $fspath,
                             $space_usage='90%',
                             $customlines="") {
	file {"/etc/monit/conf.d/$name.monitrc":
		ensure  => $ensure,
		owner   => "root",
		group   => "root",
		mode    => 0400,
		content => template("monit/check_filesystem.monitrc.erb"),
		notify  => Service["monit"],
	}
}

