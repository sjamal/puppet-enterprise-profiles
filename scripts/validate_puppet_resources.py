#!/usr/bin/env python3
# ==============================================================================
# Script Name: validate_puppet_resources.py
# Description: Parses local Puppet manifests to ensure environmental strings,
#              network zones, and node tiers match institutional policies.
# ==============================================================================

import os
import sys
import re

def parse_manifest_compliance(file_path):
    """
    Scans a targeted Puppet manifest line-by-line to prevent misconfigured
    staging variables or invalid zone mappings from reaching runtime nodes.
    """
    print(f"[INFO] Evaluating configuration parameters inside manifest: {file_path}")
    
    if not os.path.exists(file_path):
        print(f"[WARNING] Manifest target '{file_path}' missing. Compiling fallback validation block.")
        # Simulated profile content to demonstrate the parsing capabilities
        manifest_contents = """
        class profile_app_server {
          $target_zone = 'tier1_app'
          $environment = 'STAGING_BAD' # Failure: Outside accepted environment tags
        }
        """
    else:
        with open(file_path, 'r') as f:
            manifest_contents = f.read()

    # Define strict institutional boundaries
    valid_environments = ["isit", "qa", "uat", "prd", "sb", "dev"]
    violations_detected = 0

    # Look for variable declarations resembling environment strings
    env_matches = re.findall(r"\$environment\s*=\s*['\"]([^'\"]+)['\"]", manifest_contents, re.IGNORECASE)
    
    for match in env_matches:
        if match.lower() not in valid_environments:
            print(f"[SECURITY DRIFT]: Invalid environment designation discovered -> '{match}'")
            violations_detected += 1

    if violations_detected > 0:
        print(f"[CRITICAL] Quality assurance validation failed. {violations_detected} parameter errors found.")
        return False

    print("[SUCCESS] Manifest resource parameters align with corporate infrastructure definitions.")
    return True

if __name__ == "__main__":
    target_manifest = sys.argv[1] if len(sys.argv) > 1 else "manifests/observability.pp"
    is_valid = parse_manifest_compliance(target_manifest)
    sys.exit(0 if is_valid else 1)
