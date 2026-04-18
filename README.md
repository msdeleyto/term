# term — Terminal bootstrap

> Configuration as code for a zsh + Oh My Zsh + Powerlevel10k terminal setup.

A single script that installs and configures a complete terminal environment from scratch. When something breaks or you move to a new machine, clone this repo and run `install.sh` — you'll have your full setup back in minutes.

All configuration lives in plain files under `config/`. The script reads them and applies idempotent named blocks to `~/.zshrc` using `write_block`; nothing is symlinked.

## Prerequisites

- **OS**: Ubuntu / Debian-based Linux
- **Tools**: `curl`, `git`, and `zsh` must be in `$PATH` (the script does not install them)

## Getting started

```bash
git clone https://github.com/msdeleyto/term.git ~/term
cd ~/term
bash install.sh
```

After it finishes:

1. Restart your terminal or run `exec zsh`.

The script is **idempotent** — re-running it skips anything already in place and applies only what has changed.

## What the script does

| Step | Action |
|------|--------|
| 1 | Verify `curl`, `git`, and `zsh` are available (exits with an error if any are missing) |
| 2 | Download MesloLGS NF fonts to `~/.local/share/fonts/p10k/` and refresh the font cache |
| 3 | Install [Oh My Zsh](https://ohmyz.sh/) (unattended) if `~/.oh-my-zsh` is absent |
| 4 | Clone [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme |
| 5 | Set `ZSH_THEME="powerlevel10k/powerlevel10k"` in `~/.zshrc` |
| 6 | Apply plugins from `config/plugins.txt` to the `plugins=(...)` line in `~/.zshrc` |
| 7 | Copy `config/p10k.zsh` to `~/.p10k.zsh` and add a source line to `~/.zshrc` |
| 8 | Copy `config/zsh_aliases` to `~/.zsh_aliases` and add a source line to `~/.zshrc` |

## Repository structure

```
term/
├── install.sh            # Bootstrap entry point
├── helpers/
│   ├── prerequisites-helper.sh   # Verifies required tools
│   ├── fonts-helper.sh           # Downloads and installs Nerd Fonts
│   ├── omz-helper.sh             # Installs Oh My Zsh and applies plugins
│   ├── p10k-helper.sh            # Clones Powerlevel10k and applies p10k config
│   └── shell-config-helper.sh    # Copies aliases and writes source line
├── lib/
│   └── utils.sh          # Shared logging functions and write_block helper
└── config/
    ├── plugins.txt       # Oh My Zsh plugins, one per line
    ├── zsh_aliases       # Shell aliases copied to ~/.zsh_aliases at install time
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

Edit [`config/zsh_aliases`](./config/zsh_aliases). On the next `bash install.sh` run the file is copied to `~/.zsh_aliases`, which is sourced by `~/.zshrc`, so changes take effect on the next shell session (or after `reload`).

### Fonts

The default font is **MesloLGS NF** (recommended by Powerlevel10k). To install a different font, edit the variables at the top of [`helpers/fonts-helper.sh`](./helpers/fonts-helper.sh):

- `FONT_NAME` — human-readable label used in log messages
- `FONT_FILES` — associative array mapping `filename.ttf` → download URL

Re-run `bash install.sh` to apply. Font files are downloaded to `~/.local/share/fonts/p10k/`; existing files are skipped (idempotent). The font cache (`fc-cache -fv`) is only refreshed when at least one new file is downloaded.

After install, set your terminal emulator's font to the installed font.

### Customising the prompt

Edit [`config/p10k.zsh`](./config/p10k.zsh) and re-run `bash install.sh` to overwrite `~/.p10k.zsh`.

Alternatively, run `p10k configure` in a live shell to go through the interactive wizard, then copy the generated `~/.p10k.zsh` back into `config/p10k.zsh`. If you do this, make sure the option-restore line appears in the `always {}` block at the end of the file — **not** inside the inner `() { emulate -L zsh }` function — otherwise alias expansion will be silently disabled in every shell session.

## Development

No build step required. To validate the script's syntax before running:

```bash
bash -n install.sh
```
