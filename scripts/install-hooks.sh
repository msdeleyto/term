#!/usr/bin/env bash
# scripts/install-hooks.sh — Install git hooks for this repository.
#
# Run once after cloning:
#   bash scripts/install-hooks.sh
#
# Installs:
#   .git/hooks/pre-commit  — runs tests + coverage check before every commit
#                            (bypass with: git commit --no-verify)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_DIR="${REPO_ROOT}/.git/hooks"

if [[ ! -d "${HOOKS_DIR}" ]]; then
  echo "ERROR: .git/hooks directory not found. Are you inside a git repository?" >&2
  exit 1
fi

cat > "${HOOKS_DIR}/pre-commit" <<'EOF'
#!/usr/bin/env bash
# Pre-commit hook: run tests with coverage enforcement.
# Bypass with: git commit --no-verify
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec bash "${REPO_ROOT}/tests/run_tests.sh" --coverage
EOF

chmod +x "${HOOKS_DIR}/pre-commit"
echo "Installed .git/hooks/pre-commit (tests + coverage on every commit)."
echo "Bypass with: git commit --no-verify"
