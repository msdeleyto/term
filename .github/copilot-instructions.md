# Copilot Instructions

## Documentation Policy

Any code change that affects behaviour, structure, conventions, or usage must be reflected in the relevant documentation before the task is considered complete. This includes:

- `README.md` — for changes visible to users (prerequisites, steps, configuration, repo structure)
- `.github/copilot-instructions.md` — for changes to architecture, conventions, or non-obvious patterns
- Inline comments in scripts — for changes to logic that isn't self-evident

## Scope

Only modify files inside this repository. Never edit files outside the repo (e.g. `~/.zshrc`, `~/.p10k.zsh`, `~/.zsh_aliases`) without explicit permission from the user.


No build step. Validate shell syntax with:
```bash
bash -n install.sh
bash -n helpers/<helper>.sh
bash -n lib/utils.sh
```

## Architecture

`install.sh` is a thin orchestrator — it sets path variables and calls five helpers in order:

1. `helpers/prerequisites-helper.sh` — checks for `curl`, `git`, `zsh`
2. `helpers/fonts-helper.sh` — downloads MesloLGS NF fonts to `~/.local/share/fonts/p10k/`; configurable via `FONT_NAME` + `FONT_FILES` at the top of the script
3. `helpers/omz-helper.sh <zshrc> <omz_dir> <plugins_file>` — installs Oh My Zsh, writes the OMZ block to `~/.zshrc`
4. `helpers/p10k-helper.sh <zshrc> <p10k_theme_dir> <p10k_src>` — clones Powerlevel10k, copies `config/p10k.zsh` to `~/.p10k.zsh`
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

### Logging
Use the functions from `lib/utils.sh` — `info`, `success`, `warn`, `error`, `step`. Do not use raw `echo` for user-facing messages.

### `config/plugins.txt` format
One plugin name per line. Lines starting with `#` and blank lines are ignored when building the `plugins=(...)` list.

### Shell strictness
`install.sh` runs with `set -euo pipefail`. Helper scripts are invoked as subprocesses and do **not** inherit this — none of them set it themselves either. New helpers should add `set -euo pipefail` near the top to match the strictness of `install.sh`.

### `config/p10k.zsh` structure
The file uses a `{ } always { }` block that temporarily sets `no_aliases` and must restore `aliases` afterwards. The restore line **must** live in the `always {}` block, not inside the inner anonymous function `() { emulate -L zsh }` — `emulate -L` scopes option changes locally, so any `setopt` inside it is undone when the function returns, leaving `no_aliases` active for the entire shell session and breaking alias expansion.

Correct structure:
```zsh
'builtin' 'setopt' 'no_aliases' ...
{
  () {
    emulate -L zsh -o extended_glob
    # ... all typeset -g config ...
  }
} always {
  (( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
  'builtin' 'unset' 'p10k_config_opts'
}
```

If replacing `config/p10k.zsh` with a freshly generated one from `p10k configure`, verify the generated file's closing structure matches this pattern before committing.

## Testing

Tests live in `tests/` and run inside a Docker container so the host environment is never touched.

```
tests/
├── run_tests.sh          # Entry point: docker build → run bats → docker rmi (cleanup always runs)
├── Dockerfile.test       # ubuntu:22.04 + curl/git/zsh + bats-core (from GitHub source)
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
