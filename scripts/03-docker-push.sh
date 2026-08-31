#!/usr/bin/env bash
# =============================================================================
# Scenario 1 — build and push the Docker image (thin wrapper).
#
#   ./03-docker-push.sh [VERSION] [REGISTRY] [REPO]
#
# Delegates to scenario-1-docker/build-and-push.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/../scenario-1-docker/build-and-push.sh" "$@"
