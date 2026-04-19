# Copilot Instructions

## Documentation Policy

Any code change that affects behaviour, structure, conventions, or usage must be reflected in the relevant documentation before the task is considered complete. This includes:

- `README.md` — for changes visible to users (prerequisites, steps, configuration, repo structure)
- `.github/copilot-instructions.md` — for changes to architecture, conventions, or non-obvious patterns
- Inline comments in scripts — for changes to logic that isn't self-evident

## Scope

Only modify files inside this repository. Never edit files outside the repo (e.g. `~/.zshrc`, `~/.p10k.zsh`, `~/.zsh_aliases`) without explicit permission from the user.

## Git commits

Commit when it makes sense to capture a meaningful unit of work — a completed feature, a bug fix, a refactor, a docs update. Each commit should:
- Have a clear, descriptive message explaining *what* and *why*
- Represent a coherent, self-contained change (not a half-done state)
- Keep the repo history useful and navigable

Do **not** commit after every file edit, and do **not** hold off until the end of a long session. Use judgment to group related changes into logical commits.


No build step. Validate shell syntax with:
```bash
bash -n install.sh
bash -n helpers/<helper>.sh
bash -n lib/utils.sh
```

> **Note:** `.bats` files use bats DSL (`@test`) and cannot be validated with `bash -n`.
> Run the full Docker test suite to verify them: `bash tests/run_tests.sh`.

### Test verification requirement

Any change to `tests/bats/` **must** be verified by running the Docker test suite before committing. Do not rely on syntax-only checks for bats files — tests must actually execute and pass.

#### bats `command` override pattern
When testing that a specific tool is detected as missing, **do not restrict `$PATH`**. PATH manipulation breaks `lib/utils.sh` and any other commands the helper relies on.

Instead, override the `command` builtin with a bash function scoped to the subprocess. In bash, functions shadow builtins; `builtin command` still reaches the real one. `export -f` propagates the override into child processes:

```bash
# ✗ Wrong — strips PATH globally; breaks echo, grep, etc. inside the helper
PATH="${tmpbin}" run bash script.sh

# ✓ Correct — shadows 'command -v zsh' only; PATH and all other commands untouched
run bash -c '
  command() { [[ "$1" == "-v" && "$2" == "zsh" ]] && return 1; builtin command "$@"; }
  export -f command
  bash /repo/helpers/prerequisites-helper.sh
'
```

## Architecture

`install.sh` is a thin orchestrator — it sets path variables and calls five helpers in order:

1. `helpers/prerequisites-helper.sh` — checks for `curl`, `git`, `zsh`
2. `helpers/fonts-helper.sh` — downloads MesloLGS NF fonts to `~/.local/share/fonts/p10k/`; configurable via `FONT_NAME` + `FONT_FILES` at the top of the script
3. `helpers/omz-helper.sh <zshrc> <omz_dir> <plugins_file>` — installs Oh My Zsh, writes the OMZ block to `~/.zshrc`
4. `helpers/p10k-helper.sh <zshrc> <p10k_theme_dir> <p10k_src>` — clones Powerlevel10k, copies `config/p10k.zsh` to `~/.p10k.zsh`, and prepends the instant prompt block to `~/.zshrc` (idempotent)
5. `helpers/shell-config-helper.sh <zshrc> <aliases_file>` — copies `config/zsh_aliases` to `~/.zsh_aliases`

Every helper sources `lib/utils.sh` at the top using a `$(dirname "${BASH_SOURCE[0]}")` relative path. Helpers receive all paths as positional arguments — not environment variables.

## Key Conventions

### Idempotent `.zshrc` writes
All multi-line blocks written to `~/.zshrc` use `write_block` from `lib/utils.sh`. This wraps content in named markers:
```
# --- BEGIN: Name ---
...content...
# --- END: Name ---
```
Re-running replaces the block in-place. Never write to `~/.zshrc` with bare `echo` or `sed` appends; always use `write_block` (multi-line) or `append_if_absent` (single line).

### Instant prompt block (top-of-file, idempotent)
The p10k instant prompt block must appear at the **top** of `~/.zshrc` and cannot use `write_block` (which appends). Use `prepend_block` from `lib/utils.sh` instead — it wraps the block in the same `BEGIN`/`END` named markers and either replaces the content in-place (if the marker exists) or prepends the block to the top of the file (if absent). Never use bare `sed` or manual `mktemp` prepends for this.

### Logging
Use the functions from `lib/utils.sh` — `info`, `success`, `warn`, `error`, `step`. Do not use raw `echo` for user-facing messages.

### `config/plugins.txt` format
One plugin name per line. Lines starting with `#` and blank lines are ignored when building the `plugins=(...)` list.

### Shell strictness
`install.sh` runs with `set -euo pipefail`. Helper scripts are invoked as subprocesses and do **not** inherit this — none of them set it themselves either. New helpers should add `set -euo pipefail` near the top to match the strictness of `install.sh`.

### `config/p10k.zsh` structure
The file uses an anonymous function `() { emulate -L zsh -o extended_glob; ... }` that contains all configuration. Options (`no_aliases`, `no_sh_glob`, `brace_expand`) are saved before and restored **after** the function closes, at the top level of the script:

```zsh
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  # ... all typeset -g config ...
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
```

The restore lines must stay **outside** (after) the anonymous function at the script's top level. Do not place them inside the `() { emulate -L zsh }` function — `emulate -L` scopes option changes locally, so any `setopt` inside it is undone when the function returns.

If replacing `config/p10k.zsh` with a freshly generated one from `p10k configure`, verify the generated file ends with this pattern.

## Testing

Tests live in `tests/` and run inside a Docker container so the host environment is never touched.

```
tests/
├── run_tests.sh          # Entry point: docker build → run bats → docker rmi (cleanup always runs)
├── Dockerfile.test       # ubuntu:22.04 + curl/fontconfig/git/zsh + bats-core (from GitHub source)
└── bats/
    ├── 01_prerequisites.bats   # PATH manipulation tests for prerequisites-helper.sh
    ├── 02_omz.bats             # setup_file runs install.sh; asserts OMZ dirs and .zshrc blocks
    ├── 03_p10k.bats            # asserts p10k theme dir, ~/.p10k.zsh, and .zshrc blocks
    └── 04_aliases.bats         # asserts ~/.zsh_aliases and alias resolution via zsh -c
```

### Conventions for new tests
- Test files are numbered `NN_name.bats` and run in order.
- Files that need a full install call `bash /repo/install.sh` inside `setup_file()`. The script is idempotent — calling it multiple times across test files is safe.
- Use `load '/opt/bats-support/load.bash'` and `load '/opt/bats-assert/load.bash'` at the top of every test file to access `assert_success`, `assert_output`, etc.
- PATH-manipulation tests (prerequisites) use a `tmpbin` directory with only the desired symlinks to simulate missing tools.

## CI

The CI workflow lives at `.github/workflows/ci.yml` and runs `bash tests/run_tests.sh` on every push to `main` and on pull requests targeting `main`.

Conventions for the workflow:
- **Runner**: always pin to `ubuntu-22.04` — do not use `ubuntu-latest` (avoids unexpected breakage when the latest label moves to a new OS version).
- **Permissions**: set `permissions: contents: read` at the workflow level (least-privilege); escalate only in the specific job/step that needs it.
