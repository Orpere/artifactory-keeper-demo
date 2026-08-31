#!/usr/bin/env bash
# =============================================================================
# Scenario 1 — build and push a Docker image to Artifact Keeper
#
#   ./build-and-push.sh [VERSION] [REGISTRY] [REPO]
#
# Defaults:
#   VERSION = 1.0.0
#   REGISTRY = artifact-keeper.devopsexpress.site
#   REPO     = docker-local
#
# Prerequisites:
#   - Docker installed and running
#   - You can authenticate to the registry:
#       docker login artifact-keeper.devopsexpress.site
#     (or export DOCKER_PASSWORD / use a credential helper)
#   - The repository 'docker-local' exists (scripts/02-bootstrap.sh)
# =============================================================================
set -euo pipefail

VERSION="${1:-1.0.0}"
REGISTRY="${2:-artifact-keeper.devopsexpress.site}"
REPO="${3:-docker-local}"

APP_NAME="greet-service"
IMAGE_REF="${REGISTRY}/${REPO}/${APP_NAME}:${VERSION}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "==> [1/5] Building image ${APP_NAME}:${VERSION}"
docker build -t "${APP_NAME}:${VERSION}" .

echo "==> [2/5] Authenticating to ${REGISTRY}"
if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker daemon is not running." >&2
  exit 1
fi
# Logs in non-interactively if DOCKER_PASSWORD is set, otherwise prompts.
if [[ -n "${DOCKER_PASSWORD:-}" ]]; then
  docker login "${REGISTRY}" -u "${DOCKER_USERNAME:-${USER:-admin}}" --password-stdin \
    <<<"${DOCKER_PASSWORD}"
else
  docker login "${REGISTRY}"
fi

echo "==> [3/5] Tagging image -> ${IMAGE_REF}"
docker tag "${APP_NAME}:${VERSION}" "${IMAGE_REF}"

echo "==> [4/5] Pushing image to Artifact Keeper"
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
