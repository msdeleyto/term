# term — Terminal bootstrap

> Configuration as code for a zsh + Oh My Zsh + Powerlevel10k terminal setup.

A single script that installs and configures a complete terminal environment from scratch. When something breaks or you move to a new machine, clone this repo and run `install.sh` — you'll have your full setup back in minutes.

All configuration lives in plain files under `config/`. The script reads them and applies changes to `~/.zshrc` in-place using `sed` and `echo`; nothing is symlinked.

## Prerequisites

- **OS**: Ubuntu / Debian-based Linux (uses `apt` for `zsh`)
- **Tools**: `curl` and `git` must be in `$PATH`
- **Permissions**: `sudo` access (only needed if `zsh` is not yet installed)

## Getting started

```bash
git clone <your-repo-url> ~/term
cd ~/term
bash install.sh
```

After it finishes:

1. Set your terminal emulator's font to **MesloLGS NF** (installed automatically to `~/.local/share/fonts/`).
2. Restart your terminal or run `exec zsh`.

The script is **idempotent** — re-running it skips anything already in place and applies only what has changed.

## What the script does

| Step | Action |
|------|--------|
| 1 | Verify `curl` and `git` are available |
| 2 | Install `zsh` via `apt` if missing |
| 3 | Install [Oh My Zsh](https://ohmyz.sh/) (unattended) if `~/.oh-my-zsh` is absent |
| 4 | Clone [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme |
| 5 | Download MesloLGS Nerd Fonts to `~/.local/share/fonts/` |
| 6 | Set `ZSH_THEME="powerlevel10k/powerlevel10k"` in `~/.zshrc` |
| 7 | Apply plugins from `config/plugins.txt` to the `plugins=(...)` line in `~/.zshrc` |
| 8 | Copy `config/p10k.zsh` to `~/.p10k.zsh` and add a source line to `~/.zshrc` |
| 9 | Add a source line for `config/aliases.zsh` to `~/.zshrc` |
| 10 | Change the default shell to `zsh` via `chsh` if not already set |

## Repository structure

```
term/
├── install.sh            # Bootstrap entry point
└── config/
    ├── plugins.txt       # Oh My Zsh plugins, one per line
    ├── aliases.zsh       # Shell aliases sourced at startup
    └── p10k.zsh          # Powerlevel10k theme configuration
```

## Configuration

### Adding plugins

Edit [`config/plugins.txt`](./config/plugins.txt) — one plugin name per line, lines starting with `#` are ignored:

```
git
zsh-autosuggestions
zsh-syntax-highlighting
```

Re-run `bash install.sh` to apply.

> **Note:** community plugins like `zsh-autosuggestions` must be cloned into  
> `~/.oh-my-zsh/custom/plugins/` first. The script does not clone them automatically.

### Adding aliases

Edit [`config/aliases.zsh`](./config/aliases.zsh). The file is sourced directly by `~/.zshrc`, so changes take effect on the next shell session (or after `reload`).

To open the file quickly from any terminal:

```bash
ealias
```

### Customising the prompt

Edit [`config/p10k.zsh`](./config/p10k.zsh) and re-run `bash install.sh` to overwrite `~/.p10k.zsh`. Alternatively, run `p10k configure` in a live shell to go through the interactive wizard, then copy the generated `~/.p10k.zsh` back into `config/p10k.zsh`.

## Development

No build step required. To validate the script's syntax before running:

```bash
bash -n install.sh
```
