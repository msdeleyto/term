# Copilot Instructions

## Validation

No build step. Validate shell syntax with:
```bash
bash -n install.sh
bash -n helpers/<helper>.sh
bash -n lib/utils.sh
```

## Architecture

`install.sh` is a thin orchestrator — it sets path variables and calls four helpers in order:

1. `helpers/prerequisites-helper.sh` — checks for `curl`, `git`, `zsh`
2. `helpers/omz-helper.sh <zshrc> <omz_dir> <plugins_file>` — installs Oh My Zsh, writes the OMZ block to `~/.zshrc`
3. `helpers/p10k-helper.sh <zshrc> <p10k_theme_dir> <p10k_src>` — clones Powerlevel10k, copies `config/p10k.zsh` to `~/.p10k.zsh`
4. `helpers/shell-config-helper.sh <zshrc> <aliases_file>` — copies `config/aliases.zsh` to `~/.aliases`

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
