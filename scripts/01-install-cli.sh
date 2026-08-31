#!/usr/bin/env bash
# =============================================================================
# Install the Artifact Keeper CLI (ak) — idempotent.
#
# Works on Linux (Arch, Ubuntu, ...) and macOS. Install methods, in order:
#   1. Homebrew (macOS, or Linux with brew)      -> brew install artifact-keeper/tap/ak
#   2. Official curl installer                   -> /usr/local/bin/ak (Linux default)
#   3. Cargo (fallback: Rust build from source)
#
# Usage:
#   ./01-install-cli.sh                       # auto-detect (brew on macOS, curl on Linux)
#   ./01-install-cli.sh --install-dir ~/.local/bin
#   ./01-install-cli.sh --method cargo        # force a method: auto | curl | brew | cargo
#
# Full manual instructions for Arch / Ubuntu / macOS:
#   docs/02-install-cli.md
# =============================================================================
set -euo pipefail

INSTALL_DIR="/usr/local/bin"
METHOD="auto"

usage() {
  echo "Usage: $0 [--install-dir <dir>] [--method auto|curl|brew|cargo]" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-dir) INSTALL_DIR="$2"; shift 2 ;;
    --method)      METHOD="$2"; shift 2 ;;
    -h|--help)     usage ;;
    *) echo "ERROR: unknown option: $1" >&2; usage ;;
  esac
done

if command -v ak >/dev/null 2>&1; then
  echo "ak CLI already installed: $(command -v ak) ($(ak --version 2>/dev/null | head -1))"
  exit 0
fi

OS="$(uname -s)"

install_via_brew() {
  command -v brew >/dev/null 2>&1 \
    || { echo "  ! Homebrew not found — skipping brew method." >&2; return 1; }
  brew install artifact-keeper/tap/ak
}

install_via_curl() {
  local dir_flag=()
  [[ "${INSTALL_DIR}" != "/usr/local/bin" ]] && dir_flag=(--install-dir "${INSTALL_DIR}")
  curl -fsSL https://raw.githubusercontent.com/artifact-keeper/artifact-keeper-cli/main/install.sh \
    | sh -s -- "${dir_flag[@]}"
}

install_via_cargo() {
  command -v cargo >/dev/null 2>&1 \
    || { echo "  ! cargo not found — skipping cargo method." >&2; return 1; }
  cargo install artifact-keeper-cli
}

echo "==> Installing the ak CLI (method: ${METHOD})"
case "${METHOD}" in
  brew)  install_via_brew ;;
  curl)  install_via_curl ;;
  cargo) install_via_cargo ;;
  auto)
    case "${OS}" in
      Darwin) install_via_brew || install_via_curl || install_via_cargo ;;
      *)      install_via_curl || install_via_cargo ;;
    esac
    ;;
  *) echo "ERROR: unknown method '${METHOD}' (use: auto|curl|brew|cargo)" >&2; exit 1 ;;
esac

# --- Verify ----------------------------------------------------------------
if ! command -v ak >/dev/null 2>&1; then
  echo "ERROR: installation failed — 'ak' is not on your PATH." >&2
  if [[ "${INSTALL_DIR}" != "/usr/local/bin" ]]; then
    echo "       If you used --install-dir, add it to your PATH first:" >&2
    echo "         export PATH=\"${INSTALL_DIR}:\$PATH\"" >&2
  fi
  echo "       Manual instructions: docs/02-install-cli.md" >&2
  exit 1
fi

echo "==> Verifying installation"
ak --version

echo
echo "Next steps:"
echo "  ./02-bootstrap.sh    # add the registry instance, log in, create repos"
