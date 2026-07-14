# ==============================================================================
# Class: puppet_enterprise_profiles::ingress_observability
# Description: Standardizes state deployment and binary installation rules for
#              Prometheus Node Exporter and Caddy proxies across hybrid nodes.
# ==============================================================================
class puppet_enterprise_profiles::ingress_observability (
  String $node_exporter_version = '1.7.0',
  String $caddy_package_ensure  = 'present',
  String $target_environment    = $facts['environment'],
  String $binary_source_url     = 'https://institutional.edu'
) {
  # ----------------------------------------------------------------------------
  # 1. Prometheus Node Exporter Binary Installation Engine
  # ----------------------------------------------------------------------------
  # Ensure the target installation workspace directory exists on the system
  file { '/opt/node_exporter':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Download the compiled binary package from a secure internal source repository
  exec { 'download_node_exporter_tarball':
    command => "/usr/bin/curl -sSL ${binary_source_url}/node_exporter-${node_exporter_version}.linux-amd64.tar.gz -o /tmp/node_exporter.tar.gz",
    creates => "/opt/node_exporter/node_exporter",
    require => File['/opt/node_exporter'],
  }

  # Extract the package and move binaries to execution spaces
  exec { 'extract_node_exporter_binary':
    command => '/usr/bin/tar -xzf /tmp/node_exporter.tar.gz --strip-components=1 -C /opt/node_exporter/',
    creates => '/opt/node_exporter/node_exporter',
    require => Exec['download_node_exporter_tarball'],
    notify  => Service['node_exporter'],
  }

  # Clean up temporary tarball files to maintain clean node storage boundaries
  file { '/tmp/node_exporter.tar.gz':
    ensure  => absent,
    require => Exec['extract_node_exporter_binary'],
  }

  file { '/etc/systemd/system/node_exporter.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_enterprise_profiles/node_exporter.service.erb'),
    notify  => Exec['systemctl-daemon-reload-observability'],
  }

  exec { 'systemctl-daemon-reload-observability':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
    notify      => Service['node_exporter'],
  }

  service { 'node_exporter':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => File['/etc/systemd/system/node_exporter.service'],
  }

  # ----------------------------------------------------------------------------
  # 2. Caddy Proxy Native Package Manager Installation Engine
  # ----------------------------------------------------------------------------
  
  # Orchestrate repository mapping based on the underlying distribution platform
  if $facts['os']['family'] == 'Debian' {
    # Ensure standard apt-transport dependencies are active
    package { 'apt-transport-https':
      ensure => present,
    }

    # Install the native distribution package using the local system package manager
    package { 'caddy':
      ensure  => $caddy_package_ensure,
      require => Package['apt-transport-https'],
    }
  }

  if $facts['os']['family'] == 'Suse' {
    # Enforce native package engine configurations for SUSE architectures
    package { 'caddy':
      ensure => $caddy_package_ensure,
      provider => 'zypper',
    }
  }

  # Deploy custom configurations if the underlying software package is managed
  file { '/etc/caddy/Caddyfile':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_enterprise_profiles/Caddyfile.erb'),
    require => Package['caddy'],
    notify  => Service['caddy'],
  }

  service { 'caddy':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package['caddy'],
  }
}
