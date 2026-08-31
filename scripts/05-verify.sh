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
#   ./05-verify.sh --pull 1.1.0          # pull a specific version
#   AK_TOKEN=<token> ./05-verify.sh      # headless
#
# Notes:
#   - The OCI tags API call uses DOCKER_USERNAME / DOCKER_PASSWORD when set,
#     otherwise it skips the call and tells you to run `docker login` first.
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
VERSION="1.0.0"
DO_PULL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pull) DO_PULL=1; shift ;;
    -h|--help)
      echo "Usage: ./05-verify.sh [--pull] [VERSION]"
      echo "  --pull     also pull the image and jar back from the registry"
      echo "  VERSION    artifact version to check (default: 1.0.0)"
      exit 0
      ;;
    --*) echo "ERROR: unknown option: $1 (try --help)" >&2; exit 1 ;;
    *)  VERSION="$1"; shift ;;
  esac
done

if [[ ! "${VERSION}" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "ERROR: invalid VERSION '${VERSION}' (allowed: letters, digits, . _ -)" >&2
  exit 1
fi

command -v ak >/dev/null 2>&1 \
  || { echo "ERROR: ak CLI not found — run ./01-install-cli.sh first." >&2; exit 1; }

echo "==> [1/4] Repositories on '${INSTANCE}'"
ak repo list --instance "${INSTANCE}"

echo
echo "==> [2/4] Docker image tags (OCI API)"
TAGS_URL="${REGISTRY}/v2/${DOCKER_REPO}/${IMAGE}/tags/list"
if [[ -n "${DOCKER_USERNAME:-}" && -n "${DOCKER_PASSWORD:-}" ]]; then
  HTTP_CODE="$(curl -s -o /tmp/ak-tags.json -w '%{http_code}' \
    -u "${DOCKER_USERNAME}:${DOCKER_PASSWORD}" "${TAGS_URL}")"
  if [[ "${HTTP_CODE}" == "200" ]]; then
    python3 -m json.tool /tmp/ak-tags.json
  else
    echo "NOTE: tags API returned HTTP ${HTTP_CODE} — is the image pushed yet?"
    echo "      (response: $(cat /tmp/ak-tags.json | head -c 200))"
  fi
  rm -f /tmp/ak-tags.json
else
  echo "NOTE: DOCKER_USERNAME / DOCKER_PASSWORD not set — skipping the tags API call."
  echo "      Run 'docker login ${REGISTRY_HOST}' first, or export both variables."
fi

echo
echo "==> [3/4] Maven artifacts in '${MAVEN_REPO}'"
ak artifact list "${MAVEN_REPO}" --instance "${INSTANCE}" || true

echo
if [[ "${DO_PULL}" == "1" ]]; then
  echo "==> [4/4] Pulling artifacts back"
  docker pull "${REGISTRY_HOST}/${DOCKER_REPO}/${IMAGE}:${VERSION}"
  JAR="/tmp/hello-lib-${VERSION}.jar"
  ak artifact pull "${MAVEN_REPO}" "com/example/hello-lib/${VERSION}/hello-lib-${VERSION}.jar" \
    -o "${JAR}" --instance "${INSTANCE}"
  ls -l "${JAR}"
  echo "    pulled jar OK — inspect it with: unzip -l ${JAR}"
else
  echo "==> [4/4] Skipped pull-back (run ./05-verify.sh --pull to fetch image + jar)"
fi

echo
echo "Verification complete."
echo "  UI:       ${REGISTRY}"
echo "  Docker:   ${REGISTRY_HOST}/${DOCKER_REPO}/${IMAGE}:${VERSION}"
echo "  Maven:    com.example:hello-lib:${VERSION}"
