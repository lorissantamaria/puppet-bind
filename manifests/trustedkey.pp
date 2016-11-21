# ex: syntax=puppet si ts=4 sw=4 et

define bind::trustedkey (
    $secret      = undef,
    $owner       = 'root',
    $group       = $::bind::defaults::bind_group,
    $keydir      = $::bind::keydir::keydir,
    $keyfile     = undef,
    $include     = true,
) {
    # Pull some platform defaults into the local scope
    $confdir = $::bind::defaults::confdir

    # Use key name as key file name if none is supplied
    $key_file_name = $keyfile ? {
        undef   => $name,
        default => $keyfile,
    }

    file { "${keydir}/${key_file_name}":
        ensure  => present,
        owner   => $owner,
        group   => $group,
        mode    => '0640',
        replace => $replace,
        content => template('bind/trusted-keys.conf.erb'),
    }

    if $include and defined(Class['bind']) {
        Package['bind'] -> File["${keydir}/${key_file_name}"] ~> Service['bind']

        concat::fragment { "bind-key-${name}":
            order   => '10',
            target  => "${confdir}/keys.conf",
            content => "include \"${keydir}/${key_file_name}\";\n",
        }
    }
}
