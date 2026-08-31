#!/usr/bin/env bash
# =============================================================================
# Scenario 1 — build and push a Docker image to Artifact Keeper
#
#   ./build-and-push.sh [VERSION] [REGISTRY] [REPO]
#
# Defaults:
#   VERSION  = 1.0.0
#   REGISTRY = artifact-keeper.devopsexpress.site
#   REPO     = docker-local
#
# Credentials:
#   - Interactive: you will be prompted by `docker login`
#   - Headless:    export DOCKER_USERNAME + DOCKER_PASSWORD (password or API token)
#
# Prerequisites:
#   - Docker installed and running
#   - The repository 'docker-local' exists (scripts/02-bootstrap.sh)
#
# Docs: docs/05-scenario-docker.md
# =============================================================================
set -euo pipefail

VERSION="${1:-1.0.0}"
REGISTRY="${2:-artifact-keeper.devopsexpress.site}"
REPO="${3:-docker-local}"

if [[ ! "${VERSION}" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "ERROR: invalid VERSION '${VERSION}' (allowed: letters, digits, . _ -)" >&2
  exit 1
fi

APP_NAME="greet-service"
IMAGE_REF="${REGISTRY}/${REPO}/${APP_NAME}:${VERSION}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "==> [1/5] Checking Docker daemon"
docker info >/dev/null 2>&1 \
  || { echo "ERROR: Docker daemon is not running — start it and try again." >&2; exit 1; }

echo "==> [2/5] Building image ${APP_NAME}:${VERSION}"
docker build -t "${APP_NAME}:${VERSION}" .

echo "==> [3/5] Authenticating to ${REGISTRY}"
if [[ -n "${DOCKER_PASSWORD:-}" ]]; then
  docker login "${REGISTRY}" \
    -u "${DOCKER_USERNAME:-${USER:-admin}}" \
    --password-stdin <<<"${DOCKER_PASSWORD}"
else
  docker login "${REGISTRY}"
fi

echo "==> [4/5] Tagging + pushing image -> ${IMAGE_REF}"
docker tag "${APP_NAME}:${VERSION}" "${IMAGE_REF}"
docker push "${IMAGE_REF}"

echo "==> [5/5] Verifying with the ak CLI"
if command -v ak >/dev/null 2>&1; then
  ak artifact list "${REPO}" --instance "${AK_INSTANCE:-demo}" \
    || echo "NOTE: ak CLI could not list artifacts — the push itself succeeded above."
else
  echo "NOTE: ak CLI not installed — run scripts/01-install-cli.sh to install it."
fi

echo
echo "Done. Image pushed: ${IMAGE_REF}"
echo "  Pull it with:  docker pull ${IMAGE_REF}"
echo "  UI:            https://${REGISTRY}"
