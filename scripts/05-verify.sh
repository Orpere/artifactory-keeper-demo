#!/usr/bin/env bash
# =============================================================================
# Verify everything ended up in the Artifact Keeper registry.
#
# Shows:
#   1. Repositories (ak repo list)
#   2. Docker image tags via the OCI API (curl /v2/.../tags/list)
#   3. Maven artifact layout via ak artifact list
#   4. Optional: pull the image back (docker pull) and the jar (ak artifact pull)
#
# Usage:
#   ./05-verify.sh                       # read-only checks
#   ./05-verify.sh --pull                # also pull image + jar back
#   AK_TOKEN=<token> ./05-verify.sh      # headless
#
# Docs: docs/07-verify-troubleshoot.md
# =============================================================================
set -euo pipefail

REGISTRY="https://artifact-keeper.devopsexpress.site"
REGISTRY_HOST="artifact-keeper.devopsexpress.site"
INSTANCE="${AK_INSTANCE:-demo}"
DOCKER_REPO="docker-local"
MAVEN_REPO="maven-local"
IMAGE="greet-service"
VERSION="${1:-1.0.0}"
DO_PULL=0
if [[ "${1:-}" == "--pull" ]]; then
  DO_PULL=1
fi

command -v ak >/dev/null 2>&1 || { echo "ERROR: ak CLI not found — run ./01-install-cli.sh first." >&2; exit 1; }

echo "==> [1/4] Repositories on '${INSTANCE}'"
ak repo list --instance "${INSTANCE}"

echo
echo "==> [2/4] Docker image tags (OCI API: ${REGISTRY}/v2/${DOCKER_REPO}/${IMAGE}/tags/list)"
curl -s -u "${AK_MAVEN_USERNAME:-}:${AK_MAVEN_PASSWORD:-}" \
  "${REGISTRY}/v2/${DOCKER_REPO}/${IMAGE}/tags/list" \
  | python3 -m json.tool 2>/dev/null \
  || echo "NOTE: unauthenticated tags/list returns 401 — expected. Login first: docker login ${REGISTRY_HOST}"

echo
echo "==> [3/4] Maven artifacts in '${MAVEN_REPO}'"
ak artifact list "${MAVEN_REPO}" --instance "${INSTANCE}" || true

echo
if [[ "${DO_PULL}" == "1" ]]; then
  echo "==> [4/4] Pulling artifacts back"
  docker pull "${REGISTRY_HOST}/${DOCKER_REPO}/${IMAGE}:${VERSION}"
  ak artifact pull "${MAVEN_REPO}" "com/example/hello-lib/${VERSION}/hello-lib-${VERSION}.jar" \
    -o "/tmp/hello-lib-${VERSION}.jar" --instance "${INSTANCE}"
  ls -l "/tmp/hello-lib-${VERSION}.jar"
  echo "    pulled jar OK (unzip -l /tmp/hello-lib-${VERSION}.jar to inspect)"
else
  echo "==> [4/4] Skipped pull-back (run ./05-verify.sh --pull to fetch image + jar)"
fi

echo
echo "Verification complete."
echo "  UI:       ${REGISTRY}"
echo "  Docker:   ${REGISTRY_HOST}/${DOCKER_REPO}/${IMAGE}:${VERSION}"
echo "  Maven:    com.example:hello-lib:${VERSION}"
