#!/usr/bin/env bash
# =============================================================================
# Scenario 2 — build and deploy a Maven artifact to Artifact Keeper
#
#   ./build-and-deploy.sh [VERSION] [REGISTRY]
#
# Defaults:
#   VERSION  = 1.0.0
#   REGISTRY = artifact-keeper.devopsexpress.site
#
# Credentials (choose one):
#   1) Export AK_MAVEN_USERNAME + AK_MAVEN_PASSWORD (password or API token)
#   2) Place your own ~/.m2/settings.xml with a <server> entry whose
#      <id> is "artifact-keeper"
#
# Prerequisites:
#   - JDK 21+ and Maven 3.9+ installed (docs/01-prerequisites.md)
#   - The repository 'maven-local' exists (scripts/02-bootstrap.sh)
# =============================================================================
set -euo pipefail

VERSION="${1:-1.0.0}"
REGISTRY="${2:-artifact-keeper.devopsexpress.site}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

command -v mvn >/dev/null 2>&1 || { echo "ERROR: mvn not found. See docs/01-prerequisites.md." >&2; exit 1; }

# --- Write a temporary settings.xml from environment variables if provided ---
SETTINGS_FLAGS=()
if [[ -n "${AK_MAVEN_USERNAME:-}" ]]; then
  PASS="${AK_MAVEN_PASSWORD:-}"
  [[ -n "${PASS}" ]] || { echo "ERROR: AK_MAVEN_PASSWORD (or API token) is required with AK_MAVEN_USERNAME." >&2; exit 1; }
  TMP_SETTINGS="$(mktemp)"
  trap 'rm -f "${TMP_SETTINGS}"' EXIT
  cat > "${TMP_SETTINGS}" <<EOF
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <servers>
    <server>
      <id>artifact-keeper</id>
      <username>${AK_MAVEN_USERNAME}</username>
      <password>${PASS}</password>
    </server>
  </servers>
</settings>
EOF
  SETTINGS_FLAGS=(-s "${TMP_SETTINGS}")
  echo "==> Using credentials from AK_MAVEN_USERNAME/AK_MAVEN_PASSWORD"
elif [[ -f "${HOME}/.m2/settings.xml" ]]; then
  echo "==> Using existing ~/.m2/settings.xml (must contain a server id 'artifact-keeper')"
else
  echo "ERROR: no credentials found.
  Either export AK_MAVEN_USERNAME + AK_MAVEN_PASSWORD, or create
  ~/.m2/settings.xml from settings.xml.example." >&2
  exit 1
fi

echo "==> [1/3] Building ${VERSION} (mvn clean package)"
mvn "${SETTINGS_FLAGS[@]}" clean package

echo "==> [2/3] Deploying to ${REGISTRY}/maven"
mvn "${SETTINGS_FLAGS[@]}" deploy

echo "==> [3/3] Verifying with the ak CLI"
if command -v ak >/dev/null 2>&1; then
  ak artifact list "maven-local" --instance "${AK_INSTANCE:-demo}" \
    || echo "NOTE: ak CLI could not list artifacts — the deploy itself succeeded above."
else
  echo "NOTE: ak CLI not installed — run scripts/01-install-cli.sh to install it."
fi

echo
echo "Done. Artifact deployed:"
echo "  ${REGISTRY}/maven/releases/com/example/hello-lib/${VERSION}/hello-lib-${VERSION}.jar"
echo "  GAV: com.example:hello-lib:${VERSION}"
