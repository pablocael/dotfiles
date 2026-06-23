#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# dotfiles sync — snapshot this machine's live config into the repo, or
# deploy the repo's config back onto a machine.
#
#   ./sync.sh backup     Copy live config from $HOME into this repo (home/),
#                        rebuilding home/ from scratch so it matches live exactly.
#   ./sync.sh restore    Copy config from this repo (home/) back into $HOME.
#   ./sync.sh scan       List anything in home/ that looks like a secret.
#
# This repo is PUBLIC, so only an explicit allowlist of non-secret config is
# synced. Secrets (ssh/gpg keys, tokens, wallets, mail accounts, browser
# profiles, kdeconnect device keys) are never included. Edit the lists below
# to add or drop items.
# ---------------------------------------------------------------------------
set -uo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STORE="$REPO/home"

# --- single-file configs (paths relative to $HOME) -------------------------
FILES=(
  # shell / env
  .bashrc .bash_logout .profile .bash_aliases .inputrc .dircolors
  .fzf.bash
  .fonts.conf .gtkrc-2.0
  # tmux  (.tmux.conf is a repo-managed symlink — see SYMLINKS below)
  .local/bin/tmux-switcher
  # gtk / qt
  .config/Trolltech.conf
  # KDE core (kdeglobals does not end in 'rc', so list it explicitly)
  .config/kdeglobals
)

# --- directory configs (paths relative to $HOME) ---------------------------
DIRS=(
  # terminals / editor
  .config/alacritty .config/kitty .config/nvim
  # gtk + kde defaults
  .config/gtk-3.0 .config/gtk-4.0 .config/kdedefaults .config/kde.org
  # KDE look & feel data
  .local/share/konsole .local/share/color-schemes .local/share/aurorae
  .local/share/plasma .local/share/kxmlgui5
  # KWin scripts (krohnkite tiling, etc.)
  .local/share/kwin
)

# --- repo-managed configs: these live IN the repo and $HOME holds a symlink
#     pointing back at home/<path>. The repo file IS the live config, so they
#     are NOT snapshotted. backup just preserves them across the rebuild;
#     restore (re)creates the $HOME symlink. Paths are relative to $HOME. -----
SYMLINKS=(
  .tmux.conf
  .config/alacritty/alacritty.toml
)

# --- every ~/.config/*rc file is captured automatically, EXCEPT names that
#     match this (mail/PIM/account/device-key configs we must not publish) ---
RC_DENY='mail|akonadi|kontact|korg|kaddress|kalendar|kdeconnect|signon|wallet'

# --- excludes applied to every copy (junk + defense-in-depth secret guard) -
EXC=(
  --exclude='.git' --exclude='.gitmodules'
  --exclude='*.swp' --exclude='*.swo' --exclude='*~'
  --exclude='.swp' --exclude='.undo' --exclude='.backup'
  --exclude='/nvim'            # self-referential symlink inside .config/nvim
  --exclude='*/Cache/' --exclude='*/cache/' --exclude='*.log'
  --exclude='*id_rsa*' --exclude='*id_ed25519*' --exclude='*.pem' --exclude='*.key'
  --exclude='*token*' --exclude='*secret*' --exclude='*credential*' --exclude='*.kwl'
)

_put() { # copy one $HOME-relative path into STORE (resolving a top-level symlink)
  local rel="$1" src="$HOME/$1"
  [ -L "$src" ] && src="$(readlink -f "$src" 2>/dev/null)"
  [ -e "$src" ] || return 0
  local dst="$STORE/$rel"
  mkdir -p "$(dirname "$dst")"
  if [ -d "$src" ]; then rsync -a  "${EXC[@]}" "$src/" "$dst/"
  else                   rsync -aL "${EXC[@]}" "$src"  "$dst"; fi
  echo "  + $rel"
}

cmd_backup() {
  echo "Rebuilding $STORE from live config…"
  # Preserve repo-managed (symlinked) files: the live config IS these repo
  # files, so stash them aside before the rebuild and put them back after,
  # rather than re-snapshotting the $HOME symlink (which would dead-link them).
  local tmp; tmp="$(mktemp -d)"; local s
  for s in "${SYMLINKS[@]}"; do
    [ -f "$STORE/$s" ] || continue
    mkdir -p "$tmp/$(dirname "$s")"; cp -a "$STORE/$s" "$tmp/$s"
  done
  rm -rf "$STORE"; mkdir -p "$STORE"
  local x
  for x in "${FILES[@]}"; do _put "$x"; done
  for x in "${DIRS[@]}";  do _put "$x"; done
  for x in "$HOME"/.config/*rc; do
    [ -e "$x" ] || continue
    local b; b="$(basename "$x")"
    if echo "$b" | grep -qiE "$RC_DENY"; then echo "  - skip (privacy): .config/$b"; continue; fi
    _put ".config/$b"
  done
  # Restore preserved files last so they win over anything a dir copy produced.
  for s in "${SYMLINKS[@]}"; do
    [ -e "$tmp/$s" ] || continue
    mkdir -p "$STORE/$(dirname "$s")"; cp -a "$tmp/$s" "$STORE/$s"
    echo "  = keep (symlinked): $s"
  done
  rm -rf "$tmp"
  echo "Backup complete. Review: git -C '$REPO' status"
}

cmd_restore() {
  [ -d "$STORE" ] || { echo "Nothing to restore ($STORE missing)"; exit 1; }
  echo "Deploying repo config -> \$HOME …"
  rsync -a "${EXC[@]}" "$STORE/" "$HOME/"
  # Point repo-managed configs at the repo file (overwrites the plain copy
  # rsync just laid down) so edits flow straight back into version control.
  local s
  for s in "${SYMLINKS[@]}"; do
    [ -e "$STORE/$s" ] || continue
    mkdir -p "$(dirname "$HOME/$s")"
    ln -sfn "$STORE/$s" "$HOME/$s"
    echo "  -> link: ~/$s -> $STORE/$s"
  done
  echo "Restore complete. Log out/in (or restart plasmashell & kwin) for KDE changes."
}

cmd_scan() {
  echo "Scanning $STORE for likely secrets…"
  grep -rIlE 'BEGIN [A-Z ]*PRIVATE KEY|(password|passwd|token|api[_-]?key|client_secret|oauth)[[:space:]]*[=:]' \
    "$STORE" 2>/dev/null || echo "  clean — no obvious secrets found"
}

case "${1:-}" in
  backup)  cmd_backup ;;
  restore) cmd_restore ;;
  scan)    cmd_scan ;;
  *) echo "usage: $(basename "$0") {backup|restore|scan}"; exit 1 ;;
esac
