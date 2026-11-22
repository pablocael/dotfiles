# dotfiles

Personal configuration backup for Linux (Kubuntu / KDE Plasma).

The live configuration on the current machine is the source of truth. Everything
under [`home/`](home/) is a snapshot of selected `$HOME` config, laid out exactly
as it sits under your home directory (e.g. `home/.bashrc`, `home/.config/nvim`,
`home/.local/share/kwin`).

## Usage

```bash
./sync.sh all             # backup + system-backup + scan (the usual refresh)
./sync.sh backup          # snapshot this machine's live config into home/
./sync.sh restore         # deploy home/ back onto $HOME (this or another machine)
./sync.sh system-backup   # snapshot machine-level settings into system/
./sync.sh system-restore  # re-apply system/ on a fresh install (sudo, asks first)
./sync.sh scan            # check home/ and system/ for anything that looks like a secret
```

### Rebuilding a machine from scratch

1. Install Kubuntu, then clone this repo.
2. `./sync.sh system-restore`: third-party apt repos and keys, every manually
   installed apt package, snaps, flatpaks, the `/etc` drop-ins, and disabled services.
3. `./sync.sh restore`: all KDE/Plasma and app settings, then log out and back in.
4. By hand: mount entries from `system/reference/fstab` (the Samba credentials
   file is not in this repo), SSH keys, and the KWallet contents.

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
- **Desktop behaviour**: `kwinrulesrc` window rules (terminal → desktop 1,
  browser → 2, messaging → 3, monitoring → 4), `.config/autostart` overrides
  (keep junk off login), `mimeapps.list` (default apps), Haruna player config,
  monitor layout (`.local/share/kscreen`)
- **Audio**: `.config/wireplumber` (Bluetooth sink never suspends, no automatic
  switch to headset/HFP mode)
- **System (`system/`)**: `/etc/docker/daemon.json`, journald/coredump caps,
  GRUB defaults, third-party apt repos + public keys, package lists (apt, snap,
  flatpak, uv tools, npm globals, NVIDIA driver), disabled services, and an
  `fstab` reference copy

## What's intentionally excluded

This repo is **public**, so secrets are never committed: SSH/GPG keys, KWallet,
auth tokens (`github-copilot`, `gh`, …), browser profiles, KDE Connect device
keys, mail/PIM account configs (`kmail`, `akonadi`, `evolution`, …), the
Samba credentials file, and `~/.config/systemd/user` (private project timers;
only the units listed in `USER_MASKS` are re-masked on restore). Edit the
allowlist and `RC_DENY` rule in [`sync.sh`](sync.sh) to adjust.
