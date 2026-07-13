# Class: profile_sles_hardening
# Enforces enterprise security baselines and OS limits for SLES 15 hosting SAP/DB2 footprints.
class puppet_enterprise_profiles::sles_hardening {

  if $facts['os']['family'] == 'Suse' {
    
    # Secure shared memory limits and kernel settings for large DB2 / SAP footprints
    sysctl { 'kernel.shmmax':
      ensure => present,
      value  => '17179869184', # 16GB example
    }

    sysctl { 'vm.max_map_count':
      ensure => present,
      value  => '2147483647', # Required for high-memory database mappings
    }

    # Ensure system security services are active
    service { 'auditd':
      ensure     => running,
      enable     => true,
      hasrestart => true,
    }

    # Restrict cron access to authorized system accounts
    file { '/etc/cron.allow':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => "root\npuppet\n",
    }
  }
}

