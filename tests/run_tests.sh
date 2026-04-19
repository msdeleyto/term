#!/usr/bin/env bash
# tests/run_tests.sh — Build a Docker test image, run bats tests inside it, then clean up.
#
# Usage:
#   bash tests/run_tests.sh             # run tests only
#   bash tests/run_tests.sh --coverage  # run tests + measure coverage (requires seccomp=unconfined)
#
# Exit code mirrors the bats/kcov exit code so CI pipelines can detect failures.
#
# Environment variables (coverage mode only):
#   COVERAGE_MIN   Minimum acceptable coverage percentage (default: 80)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COVERAGE=false
COVERAGE_MIN="${COVERAGE_MIN:-80}"

for arg in "$@"; do
  [[ "$arg" == "--coverage" ]] && COVERAGE=true
done

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

if [[ "${COVERAGE}" == "true" ]]; then
  echo "Running tests with coverage (kcov)..."
  # --security-opt seccomp=unconfined is required for kcov's ptrace instrumentation
  docker run --rm \
    --security-opt seccomp=unconfined \
    "${IMAGE_NAME}" \
    bash -c "
      kcov \
        --include-path=/repo/lib,/repo/helpers,/repo/install.sh \
        --exclude-pattern=/repo/tests \
        /tmp/cov \
        bats /repo/tests/bats/

      echo ''
      echo '── Coverage report ──────────────────────────────────────────────────────────'
      json=\$(find /tmp/cov -name 'coverage.json' | head -1)
      pct=\$(python3 -c \"import json,sys; d=json.load(open('\${json}')); print(d['percent_covered'])\" 2>/dev/null || echo 0)
      pct_int=\${pct%.*}
      echo \"Coverage: \${pct}% (minimum: ${COVERAGE_MIN}%)\"
      echo ''

      if (( pct_int < ${COVERAGE_MIN} )); then
        echo \"ERROR: Coverage \${pct}% is below minimum ${COVERAGE_MIN}%.\" >&2
        exit 1
      fi
      echo 'Coverage check passed.'
    "
else
  echo "Running tests..."
  docker run --rm "${IMAGE_NAME}" bats /repo/tests/bats/
fi
