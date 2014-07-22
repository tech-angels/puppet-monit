# Define: monit::check::url
# Creates a monit http check,
#
# Parameters:
#   url         - URL
#   content     - expected content
#

define monit::check::url(
  $ensure=present,
  $url,
  $content=false,
) {
	file {"/etc/monit/conf.d/url-${name}.monitrc":
		ensure  => $ensure,
		owner   => "root",
		group   => "root",
		mode    => 0400,
		content => template("monit/check_url.monitrc.erb"),
		notify  => Service["monit"],
	}
}

