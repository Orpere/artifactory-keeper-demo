#!/usr/bin/env bash
# =============================================================================
# Bootstrap the ak CLI against your Artifact Keeper instance:
#
#   1. ak instance add demo <registry-url>     (saves the server as 'demo')
#   2. ak auth login                           (Keycloak browser SSO, or --token)
#   3. ak repo create docker-local (docker)    (idempotent)
#   4. ak repo create maven-local (maven)      (idempotent)
#
# Usage:
#   ./02-bootstrap.sh                          # interactive browser SSO
#   AK_TOKEN=<token> ./02-bootstrap.sh         # fully headless
#   ./02-bootstrap.sh --registry https://your-registry.example.com
#
# Environment:
#   AK_INSTANCE   instance name (default: demo)
#   AK_TOKEN      API token -> skips browser login entirely
#   AK_NO_INPUT=1 forces non-interactive mode (fails if a token is needed)
#
# Docs: docs/03-connect-auth.md and docs/04-repositories.md
# =============================================================================
set -euo pipefail

REGISTRY="https://artifact-keeper.devopsexpress.site"
INSTANCE="${AK_INSTANCE:-demo}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --registry) REGISTRY="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

command -v ak >/dev/null 2>&1 || { echo "ERROR: ak CLI not found — run ./01-install-cli.sh first." >&2; exit 1; }

echo "==> [1/4] Saving instance '${INSTANCE}' -> ${REGISTRY}"
if ak instance list | grep -qE "^\s*${INSTANCE}\b"; then
  echo "    instance '${INSTANCE}' already exists, skipping"
else
  ak instance add "${INSTANCE}" "${REGISTRY}"
fi
ak instance use "${INSTANCE}"

echo "==> [2/4] Authenticating"
if [[ -n "${AK_TOKEN:-}" ]]; then
  echo "    using AK_TOKEN (headless mode)"
elif [[ "${AK_NO_INPUT:-0}" == "1" ]]; then
  echo "ERROR: AK_NO_INPUT=1 but AK_TOKEN is not set." >&2
  exit 1
else
  echo "    a browser will open for Keycloak SSO (or run 'ak auth login --token' to paste a token)"
  ak auth login
fi
ak auth whoami || true

echo "==> [3/4] Creating repository 'docker-local' (format: docker)"
ak repo create docker-local --pkg-format docker --repo-type local 2>/dev/null \
  && echo "    created docker-local" \
  || echo "    docker-local already exists (or was created by someone else) — continuing"

echo "==> [4/4] Creating repository 'maven-local' (format: maven)"
ak repo create maven-local --pkg-format maven --repo-type local 2>/dev/null \
  && echo "    created maven-local" \
  || echo "    maven-local already exists — continuing"

echo
echo "Bootstrap complete. Verify with:"
echo "  ak repo list --format table"
echo "Next: ./03-docker-push.sh   (Scenario 1) and ./04-maven-deploy.sh (Scenario 2)"
