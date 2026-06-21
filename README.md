# dotfiles

Personal configuration backup for Linux (Kubuntu / KDE Plasma).

The live configuration on the current machine is the source of truth. Everything
under [`home/`](home/) is a snapshot of selected `$HOME` config, laid out exactly
as it sits under your home directory (e.g. `home/.bashrc`, `home/.config/nvim`,
`home/.local/share/kwin`).

## Usage

```bash
./sync.sh backup     # snapshot this machine's live config into home/
./sync.sh restore    # deploy home/ back onto $HOME (this or another machine)
./sync.sh scan       # check home/ for anything that looks like a secret
```

`backup` rebuilds `home/` from scratch so the repo always matches live config.

## What's included

- **Shell / env**: `.bashrc`, `.profile`, `.bash_logout`, `.inputrc`, `.dircolors`,
  `.fzf.bash`, `.gitconfig`, `.gitconfig-personal`, `.fonts.conf`, `.gtkrc-2.0`
- **tmux**: `.tmux.conf`
- **Terminals / editor**: `.config/alacritty`, `.config/kitty`, `.config/nvim`
- **KDE / Plasma**: `kdeglobals` + all `~/.config/*rc` (kwin, plasma, shortcuts,
  dolphin, kate, konsole, …), `kdedefaults`, `kde.org`, GTK settings, and the
  KDE data dirs `konsole`, `color-schemes`, `aurorae`, `plasma`, `kxmlgui5`
- **KWin scripts**: `.local/share/kwin` (Krohnkite tiling, etc.)

## What's intentionally excluded

This repo is **public**, so secrets are never committed: SSH/GPG keys, KWallet,
auth tokens (`github-copilot`, `gh`, …), browser profiles, KDE Connect device
keys, and mail/PIM account configs (`kmail`, `akonadi`, `evolution`, …). Edit the
allowlist and `RC_DENY` rule in [`sync.sh`](sync.sh) to adjust.
