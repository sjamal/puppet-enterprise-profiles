# Puppet Enterprise Profiles & Configuration Matrix

Production-ready Puppet 8 open-source manifests engineered to enforce cross-platform operating patterns, continuous compliance, performance tuning, application edge configuration structures, parameter allocation validations, standard system metrics agents, and other lifecycle operations across hybrid infrastructure footprints.

## Core Operational Components
- **Observability Frameworks (`manifests/observability.pp` & `templates/node_exporter.service.erb`):** Enforces structured configuration matrices for monitoring utilities (**Prometheus Node Exporters**) across environments to maintain metrics collection consistency.
- **Integration Management:** Structures base file configurations for web proxies, reverse proxies, and certificate validation frameworks.
- **Service Standardizations:** Centralizes execution configurations for process supervisors, logging patterns, and state tracking utilities.
- **Resource Allocation Parser (`scripts/validate_puppet_resources.py`):** Parses local Puppet manifests to ensure environmental strings, network zones, and node tiers match institutional policies before compilation.
- **Automated Validation Framework (`.azure-pipelines/puppet-validation-ci.yml`):** Continuous Integration quality assurance framework executing syntax checking, manifest layout linting, and dry-run parser syntax verification.

## Key Features
- **SLES 15 Enterprise Hardening:** Tailored configuration for SUSE Linux Enterprise Server hosting SAP and IBM DB2 applications, adjusting memory management (`sysctl`) and persistent host firewall definitions (`iptables`).
- **Autosign Workflows:** Structured configurations to support Puppet CA policy-based autosigning for secure, frictionless onboarding of newly provisioned on-premises VMware hosts.
- **Observability Automation:** Installs and dynamically configures Prometheus Node Exporters and Caddy reverse proxies across staging boundaries (**ISIT, QA, UAT, PRD**).

## Repository Component Matrix
- **manifests/init.pp:** Central configuration initialization layout mapping secondary supporting runtime utilities.
- **manifests/observability.pp:** Installs and manages telemetry collectors.
- **scripts/validate_puppet_resources.py:** Validates resource definitions against operational baselines.
- **.azure-pipelines/puppet-validation-ci.yml:** Verification workflow processing code linter routines.

## Running Resource Allocation Scans
To validate manifest properties and variable strings locally before submitting code modifications, execute the parsing script below:

```bash
# Execute parameter verification checks against a target class manifest
python scripts/validate_puppet_resources.py "manifests/observability.pp"
```

## Related Enterprise Projects

Part of the integrated enterprise configuration management ecosystem:

- **[puppet-sles-hardening](https://github.com/sjamal/puppet-sles-hardening)** — CIS hardening profiles for SLES
- **[hybrid-governance-automation](https://github.com/sjamal/hybrid-governance-automation)** — Orchestration and gating
- **[enterprise-hybrid-pipelines](https://github.com/sjamal/enterprise-hybrid-pipelines)** — Post-provisioning automation
- **[enterprise-network-mesh](https://github.com/sjamal/enterprise-network-mesh)** — Network configuration
- **[ansible](https://github.com/sjamal/ansible)** — Complementary provisioning framework
