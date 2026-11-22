#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# dotfiles sync — snapshot this machine's live config into the repo, or
# deploy the repo's config back onto a machine.
#
#   ./sync.sh backup     Copy live config from $HOME into this repo (home/),
#                        rebuilding home/ from scratch so it matches live exactly.
#   ./sync.sh restore    Copy config from this repo (home/) back into $HOME.
#   ./sync.sh scan       List anything in home/ or system/ that looks like a secret.
#   ./sync.sh system-backup   Snapshot machine-level settings into system/
#                        (/etc drop-ins, apt repos + keys, package lists,
#                        disabled services). No sudo needed.
#   ./sync.sh system-restore  Re-apply system/ on a fresh install (uses sudo).
#   ./sync.sh all        backup + system-backup.
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
  # default apps per file type (Haruna for video, etc.)
  .config/mimeapps.list
  # video player (StopAfterLast: play-after-end restarts the video)
  .config/haruna/haruna.conf
  # Dolphin / file dialogs: Places panel order + grouped Bookmarks menu
  .local/share/user-places.xbel
  .local/share/dolphin/bookmarks.xml
)

# --- directory configs (paths relative to $HOME) ---------------------------
DIRS=(
  # terminals / editor
  .config/alacritty .config/kitty .config/fastfetch   # .config/nvim is repo-managed — see SYMLINKS
  # gtk + kde defaults
  .config/gtk-3.0 .config/gtk-4.0 .config/kdedefaults .config/kde.org
  # KDE look & feel data
  .local/share/konsole .local/share/color-schemes .local/share/aurorae
  .local/share/plasma .local/share/kxmlgui5
  # KWin scripts (krohnkite tiling, etc.)
  .local/share/kwin
  # login autostart overrides (Hidden=true entries that keep junk off startup)
  .config/autostart
  # PipeWire/WirePlumber drop-ins (BT sink never suspends, no HFP autoswitch)
  .config/wireplumber
  # monitor layout / scaling
  .local/share/kscreen
)

# --- user systemd units to mask on restore (kept out of the repo as files:
#     ~/.config/systemd/user also holds private kino-* production timers) ----
USER_MASKS=(
  drkonqi-coredump-launcher.socket   # Playwright WebKit crashes spawned stuck KDE crash handlers
)

# --- machine-level settings (system/) ---------------------------------------
SYS="$REPO/system"
# /etc files that were deliberately customised (copied as-is, restored as-is)
SYS_ETC=(
  /etc/docker/daemon.json                     # data-root on /mnt/data, 10.200/10.201 pools (VPN-safe)
  /etc/systemd/coredump.conf.d/50-limit.conf  # cap coredumps at 2G
  /etc/systemd/journald.conf.d/50-size.conf   # cap journal at 1G
  /etc/default/grub                           # hidden menu, timeout 0
)
# reference-only copies: saved for a human to read, never restored blindly
SYS_REF=(
  /etc/fstab        # UUIDs change on reinstall; the cifs credentials file itself is NOT saved
)
# system services that stay disabled on this machine
SYS_DISABLED=(
  ModemManager.service   # no modem
  cups-browsed.service   # no printers; avoids auto-discovered network printers
)

# --- repo-managed configs: these live IN the repo and $HOME holds a symlink
#     pointing back at home/<path>. The repo file IS the live config, so they
#     are NOT snapshotted. backup just preserves them across the rebuild;
#     restore (re)creates the $HOME symlink. Paths are relative to $HOME. -----
SYMLINKS=(
  .tmux.conf
  .config/alacritty/alacritty.toml
  .config/nvim
)

# --- every ~/.config/*rc file is captured automatically, EXCEPT names that
#     match this (mail/PIM/account/device-key configs we must not publish) ---
RC_DENY='mail|akonadi|kontact|korg|kaddress|kalendar|kdeconnect|signon|wallet'

# --- excludes applied to every copy (junk + defense-in-depth secret guard) -
EXC=(
  --exclude='.git' --exclude='.gitmodules'
  --exclude='*.swp' --exclude='*.swo' --exclude='*~' --exclude='*.bak-*'
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
    [ -e "$STORE/$s" ] || continue
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
    # a dir copy may have left the $HOME symlink here (pointing at itself)
    rm -rf "${STORE:?}/$s"
    mkdir -p "$STORE/$(dirname "$s")"; cp -a "$tmp/$s" "$STORE/$s"
    echo "  = keep (symlinked): $s"
  done
  rm -rf "$tmp"
  echo "Backup complete. Review: git -C '$REPO' status"
}

cmd_restore() {
  [ -d "$STORE" ] || { echo "Nothing to restore ($STORE missing)"; exit 1; }
  echo "Deploying repo config -> \$HOME …"
  local s skip=()
  for s in "${SYMLINKS[@]}"; do skip+=(--exclude="/$s"); done
  rsync -a "${EXC[@]}" "${skip[@]}" "$STORE/" "$HOME/"
  # Point repo-managed configs at the repo file (overwrites the plain copy
  # rsync just laid down) so edits flow straight back into version control.
  for s in "${SYMLINKS[@]}"; do
    [ -e "$STORE/$s" ] || continue
    # move a real file/dir aside so ln doesn't nest the link inside it
    if [ -e "$HOME/$s" ] && [ ! -L "$HOME/$s" ]; then
      mv "$HOME/$s" "$HOME/$s.pre-dotfiles.$(date +%s)"
    fi
    mkdir -p "$(dirname "$HOME/$s")"
    ln -sfn "$STORE/$s" "$HOME/$s"
    echo "  -> link: ~/$s -> $STORE/$s"
  done
  for s in "${USER_MASKS[@]}"; do
    systemctl --user mask "$s" >/dev/null 2>&1 && echo "  -> masked user unit: $s"
  done
  systemctl --user restart wireplumber >/dev/null 2>&1 || true
  echo "Restore complete. Log out/in (or restart plasmashell & kwin) for KDE changes."
}

cmd_scan() {
  echo "Scanning $STORE and $SYS for likely secrets…"
  grep -rIlE 'BEGIN [A-Z ]*PRIVATE KEY|(password|passwd|token|api[_-]?key|client_secret|oauth)[[:space:]]*[=:]' \
    "$STORE" "$SYS" 2>/dev/null || echo "  clean — no obvious secrets found"
}

# --- system/ ----------------------------------------------------------------
cmd_system_backup() {
  echo "Rebuilding $SYS from this machine…"
  rm -rf "$SYS"; mkdir -p "$SYS/etc" "$SYS/reference" "$SYS/packages"
  local f
  for f in "${SYS_ETC[@]}"; do
    [ -r "$f" ] || { echo "  ! missing $f"; continue; }
    mkdir -p "$SYS/etc$(dirname "$f")"; cp -a "$f" "$SYS/etc$f"; echo "  + $f"
  done
  for f in "${SYS_REF[@]}"; do [ -r "$f" ] && cp "$f" "$SYS/reference/$(basename "$f")" && echo "  + $f (reference)"; done
  # third-party apt repos + their public signing keys (ubuntu.sources is stock)
  mkdir -p "$SYS/etc/etc/apt/sources.list.d" "$SYS/etc/etc/apt/keyrings" "$SYS/etc/usr/share/keyrings"
  for f in /etc/apt/sources.list.d/*.sources /etc/apt/sources.list.d/*.list; do
    [ -e "$f" ] || continue; [ "$(basename "$f")" = ubuntu.sources ] && continue
    cp -a "$f" "$SYS/etc/etc/apt/sources.list.d/"
  done
  cp -a /etc/apt/keyrings/. "$SYS/etc/etc/apt/keyrings/" 2>/dev/null || true
  for f in /usr/share/keyrings/*; do
    case "$(basename "$f")" in ubuntu-*|debian-*) continue ;; esac
    cp -a "$f" "$SYS/etc/usr/share/keyrings/"
  done
  echo "  + apt repos: $(ls "$SYS/etc/etc/apt/sources.list.d" | wc -l), keys: $(ls "$SYS/etc/etc/apt/keyrings" "$SYS/etc/usr/share/keyrings" | grep -vc ':$')"
  # package lists
  apt-mark showmanual | sort > "$SYS/packages/apt-manual.txt"
  { dpkg -l 'nvidia-driver-*' 2>/dev/null | awk '/^ii/{print $2}'; } > "$SYS/packages/nvidia-driver.txt"
  command -v snap    >/dev/null && snap list 2>/dev/null | awk 'NR>1{print $1, $4}' > "$SYS/packages/snap.txt"
  command -v flatpak >/dev/null && flatpak list --app --columns=application,origin 2>/dev/null | sort > "$SYS/packages/flatpak.txt"
  command -v flatpak >/dev/null && flatpak remotes --columns=name,url 2>/dev/null > "$SYS/packages/flatpak-remotes.txt"
  command -v uv      >/dev/null && uv tool list 2>/dev/null | grep -v '^-' > "$SYS/packages/uv-tools.txt"
  command -v npm     >/dev/null && npm ls -g --depth=0 --parseable 2>/dev/null | tail -n +2 | xargs -rn1 basename > "$SYS/packages/npm-global.txt"
  printf '%s\n' "${SYS_DISABLED[@]}" > "$SYS/packages/disabled-services.txt"
  echo "  + packages: apt $(wc -l < "$SYS/packages/apt-manual.txt"), snap $(wc -l < "$SYS/packages/snap.txt" 2>/dev/null || echo 0), flatpak $(wc -l < "$SYS/packages/flatpak.txt" 2>/dev/null || echo 0)"
  echo "System backup complete. Review: git -C '$REPO' status"
}

cmd_system_restore() {
  [ -d "$SYS" ] || { echo "Nothing to restore ($SYS missing)"; exit 1; }
  cat <<EOF
This re-applies system/ to THIS machine with sudo:
  - copies /etc drop-ins (docker, journald, coredump, grub) and third-party apt repos + keys
  - apt update, then installs every package in system/packages/apt-manual.txt that apt can find
  - installs snaps and flatpaks from the lists, disables: ${SYS_DISABLED[*]}
fstab is NOT touched (see system/reference/fstab). Intended for a fresh install.
EOF
  read -r -p "Continue? [y/N] " ok; [ "${ok,,}" = y ] || { echo "aborted"; exit 1; }
  # system/etc mirrors / (etc/..., usr/share/keyrings/...); force root ownership
  sudo rsync -rltO --chown=root:root --chmod=D755,F644 "$SYS/etc/" /
  sudo apt-get update
  local avail; avail=$(comm -12 <(sort -u "$SYS/packages/apt-manual.txt") <(apt-cache pkgnames | sort -u))
  # shellcheck disable=SC2086
  sudo apt-get install -y $avail
  [ -s "$SYS/packages/snap.txt" ] && while read -r name channel; do
    snap list "$name" >/dev/null 2>&1 || sudo snap install "$name" --channel="${channel:-latest/stable}" --classic 2>/dev/null || sudo snap install "$name" || true
  done < "$SYS/packages/snap.txt"
  [ -s "$SYS/packages/flatpak.txt" ] && while read -r app origin; do
    flatpak install -y --noninteractive "${origin:-flathub}" "$app" || true
  done < "$SYS/packages/flatpak.txt"
  sudo systemctl disable --now "${SYS_DISABLED[@]}" 2>/dev/null || true
  sudo update-grub
  sudo systemctl restart systemd-journald
  systemctl is-active --quiet docker && sudo systemctl restart docker
  echo "System restore complete. Then run: ./sync.sh restore   (user/KDE settings), and reboot."
}

case "${1:-}" in
  backup)         cmd_backup ;;
  restore)        cmd_restore ;;
  scan)           cmd_scan ;;
  system-backup)  cmd_system_backup ;;
  system-restore) cmd_system_restore ;;
  all)            cmd_backup; cmd_system_backup; cmd_scan ;;
  *) echo "usage: $(basename "$0") {backup|restore|scan|system-backup|system-restore|all}"; exit 1 ;;
esac
