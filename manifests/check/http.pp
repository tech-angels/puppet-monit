# Define: monit::check::http
# Creates a monit http check,
#
# Parameters:
#   port        - TCP port
#   request     - the request path. Ex: /toto.html
#

define monit::check::http(
  $ensure=present,
  $port=80,
  $request=false,
) {
	file {"/etc/monit/conf.d/http-${name}.monitrc":
		ensure  => $ensure,
		owner   => "root",
		group   => "root",
		mode    => 0400,
		content => template("monit/check_http.monitrc.erb"),
		notify  => Service["monit"],
	}
}

