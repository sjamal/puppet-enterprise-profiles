# ==============================================================================
# Class: puppet_enterprise_profiles::ingress_observability
# Description: Standardizes state deployment rules for Prometheus Node Exporter
#              telemetry daemons and Caddy reverse proxies on enterprise nodes.
# ==============================================================================
class puppet_enterprise_profiles::ingress_observability (
  String $node_exporter_version = '1.7.0',
  String $caddy_package_ensure  = 'present',
  String $target_environment    = $facts['environment']
) {

  # ----------------------------------------------------------------------------
  # 1. Prometheus Node Exporter Provisioning Configuration
  # ----------------------------------------------------------------------------
  file { '/opt/node_exporter':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Build the tracking service layer background process template
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
  # 2. Caddy Reverse Proxy & Boundary Route Routing
  # ----------------------------------------------------------------------------
  # Ensure the underlying repository package availability for appropriate OS family
  if $facts['os']['family'] == 'Debian' {
    package { 'caddy':
      ensure => $caddy_package_ensure,
    }

    # Enforce corporate global reverse proxy properties via structured source templates
    file { '/etc/caddy/Caddyfile':
      ensure  => file,
      owner   => 'caddy',
      group   => 'caddy',
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
}
