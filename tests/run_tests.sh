#!/usr/bin/env bash
# tests/run_tests.sh — Build a Docker test image, run bats tests inside it, then clean up.
#
# Usage:  bash tests/run_tests.sh
#
# Exit code mirrors the bats exit code so CI pipelines can detect failures.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Preflight: Docker must be reachable ──────────────────────────────────────
if ! docker info &>/dev/null; then
  echo "ERROR: Cannot reach the Docker daemon." >&2
  echo "  Make sure Docker is running and your user is in the 'docker' group:" >&2
  echo "    sudo usermod -aG docker \$USER" >&2
  echo "  Then start a new shell session (or run: newgrp docker) and try again." >&2
  exit 1
fi
IMAGE_NAME="term-test"

cleanup() {
  echo ""
  echo "Removing test image..."
  docker rmi "${IMAGE_NAME}" --force 2>/dev/null || true
}
trap cleanup EXIT

echo "Building test image..."
docker build --quiet -f "${REPO_ROOT}/tests/Dockerfile.test" -t "${IMAGE_NAME}" "${REPO_ROOT}"

echo "Running tests..."
docker run --rm "${IMAGE_NAME}" bats /repo/tests/bats/
