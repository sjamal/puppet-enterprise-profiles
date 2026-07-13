# Class: puppet_enterprise_profiles::observability
# deploys and standardizes system metrics exporters and application edge reverse proxies.
class puppet_enterprise_profiles::observability (
  String $prometheus_version = '1.7.0',
  String $target_environment = 'QA'
) {

  # Deployment structure for Prometheus monitoring collector
  file { '/opt/node_exporter':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Configures tracking daemon background execution interfaces via system components
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
    ensure => running,
    enable => true,
  }
}

