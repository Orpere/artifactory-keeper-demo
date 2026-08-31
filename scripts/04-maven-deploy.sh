#!/usr/bin/env bash
# =============================================================================
# Scenario 2 — build and deploy the Maven artifact (thin wrapper).
#
#   ./04-maven-deploy.sh [VERSION] [REGISTRY]
#
# Delegates to scenario-2-maven/build-and-deploy.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/../scenario-2-maven/build-and-deploy.sh" "$@"
