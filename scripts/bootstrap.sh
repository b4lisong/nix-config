#!/usr/bin/env bash
# bootstrap.sh - set up a machine from this flake.
#
# Usage: scripts/bootstrap.sh [options] <host>
#
# Detects the platform (nix-darwin or NixOS), checks that <host> exists in
# outputs/<arch>/src/ for this architecture, and performs the first
# activation. Every step checks whether it is already done, so re-running
# after a failure is safe.
#
# Works from a checkout or piped from GitHub on a fresh machine:
#   curl -fsSL https://raw.githubusercontent.com/b4lisong/nix-config/main/scripts/bootstrap.sh | bash -s -- <host>
#
# Must stay compatible with bash 3.2 (the macOS system bash): no associative
# arrays, no ${var,,}, no mapfile.

set -euo pipefail

REPO_URL="https://github.com/b4lisong/nix-config.git"
CLONE_DIR="${HOME}/dev/nix-config"
NIX_INSTALLER_URL="https://install.determinate.systems/nix"
HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
DISKO_REF="github:nix-community/disko/latest"
NIX_DAEMON_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

# Flakes are enabled by modules/base.nix, which is not active until the
# first activation, so enable them for every nix invocation here.
export NIX_CONFIG="extra-experimental-features = nix-command flakes${NIX_CONFIG:+
$NIX_CONFIG}"

HOST=""
INSTALL=0
DRY_RUN=0
ASSUME_YES=0
ORIG_ARGS=("$@")

OS=""             # darwin | linux
SYSTEM=""         # e.g. aarch64-darwin
REPO=""           # absolute path to the flake checkout
HOST_DIR=""       # hosts/<platform>-<host>
HW_CHANGED=0

# --- output helpers ---------------------------------------------------------

if [ -t 2 ]; then
  C_BOLD=$'\033[1m' C_YELLOW=$'\033[33m' C_RED=$'\033[31m' C_RESET=$'\033[0m'
else
  C_BOLD="" C_YELLOW="" C_RED="" C_RESET=""
fi

step() { printf '\n%s==> %s%s\n' "$C_BOLD" "$*" "$C_RESET" >&2; }
info() { printf '    %s\n' "$*" >&2; }
warn() { printf '%swarning:%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
die() {
  printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2
  exit 1
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] <host>

Bootstrap this machine as <host> from the nix-config flake.

  nix-darwin  Installs Nix and Homebrew if missing, sets the hostname, moves
              aside /etc shell files, and runs the first darwin-rebuild switch.
  NixOS       Offers to refresh hardware-configuration.nix, then runs
              nixos-rebuild switch.

Options:
  --install    Fresh NixOS install from the live ISO: partition and format
               with hosts/linux-<host>/disks.nix (ERASES DISKS), regenerate
               hardware-configuration.nix, run nixos-install, and copy the
               repo into the new system. Asks you to type the host name to
               confirm, even with --yes.
  -n, --dry-run
               Print the commands that would change the system, without
               running them. Read-only checks still run.
  -y, --yes    Accept the default answer to every prompt.
  -h, --help   Show this help.

Hosts available:
EOF
  list_hosts | sed 's/^/  /'
}

list_hosts() {
  local f arch
  [ -n "$REPO" ] || {
    echo "(run from a checkout to list hosts)"
    return
  }
  for f in "$REPO"/outputs/*/src/*.nix; do
    [ -f "$f" ] || continue
    arch=$(basename "$(dirname "$(dirname "$f")")")
    printf '%-14s %s\n' "$(basename "$f" .nix)" "$arch"
  done
}

# Run a command that changes the system, or print it under --dry-run.
run() {
  printf '    +' >&2
  printf ' %q' "$@" >&2
  printf '\n' >&2
  [ "$DRY_RUN" = 1 ] && return 0
  "$@"
}

# confirm <prompt> <default y|n>
confirm() {
  local ans
  if [ "$ASSUME_YES" = 1 ]; then
    [ "$2" = y ]
    return
  fi
  if [ "$2" = y ]; then
    read -r -p "    $1 [Y/n] " ans </dev/tty
  else
    read -r -p "    $1 [y/N] " ans </dev/tty
  fi
  case "${ans:-$2}" in
    [Yy]*) return 0 ;;
    *) return 1 ;;
  esac
}

# --- arguments --------------------------------------------------------------

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --install) INSTALL=1 ;;
      -n | --dry-run) DRY_RUN=1 ;;
      -y | --yes) ASSUME_YES=1 ;;
      -h | --help)
        locate_repo
        usage
        exit 0
        ;;
      -*) die "unknown option: $1 (see --help)" ;;
      *)
        [ -z "$HOST" ] || die "only one host may be given"
        HOST="$1"
        ;;
    esac
    shift
  done
  [ -n "$HOST" ] || die "missing <host> argument (see --help)"
  [[ "$HOST" =~ ^[A-Za-z0-9][A-Za-z0-9-]*$ ]] || die "invalid host name: $HOST"
}

# --- detection --------------------------------------------------------------

detect_platform() {
  local arch
  case "$(uname -s)" in
    Darwin) OS=darwin ;;
    Linux) OS=linux ;;
    *) die "unsupported OS: $(uname -s)" ;;
  esac

  case "$(uname -m)" in
    x86_64 | amd64) arch=x86_64 ;;
    arm64 | aarch64) arch=aarch64 ;;
    *) die "unsupported architecture: $(uname -m)" ;;
  esac

  # A shell running under Rosetta reports x86_64 on Apple Silicon.
  if [ "$OS" = darwin ] && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = 1 ]; then
    arch=aarch64
  fi

  SYSTEM="$arch-$OS"

  if [ "$OS" = linux ] && ! is_nixos; then
    die "this Linux system is not NixOS; only NixOS hosts are supported"
  fi
}

is_nixos() { [ -e /etc/NIXOS ] || grep -qs '^ID=nixos' /etc/os-release; }

# The NixOS installer ISO mounts its read-only store here.
is_live_iso() { [ -d /nix/.ro-store ]; }

# Sets REPO if this script is running from inside a checkout.
locate_repo() {
  local src="${BASH_SOURCE[0]:-}" dir
  [ -n "$src" ] && [ -f "$src" ] || return 0
  dir=$(cd "$(dirname "$src")/.." && pwd)
  [ -f "$dir/flake.nix" ] && [ -d "$dir/outputs" ] && REPO="$dir"
  return 0
}

validate_host() {
  local matches=() f host_system
  for f in "$REPO"/outputs/*/src/"$HOST".nix; do
    [ -f "$f" ] && matches+=("$f")
  done

  if [ ${#matches[@]} -eq 0 ]; then
    printf 'Hosts available:\n' >&2
    list_hosts | sed 's/^/  /' >&2
    die "no host '$HOST' in outputs/*/src/"
  fi
  [ ${#matches[@]} -eq 1 ] || die "host '$HOST' is defined for more than one architecture"

  host_system=$(basename "$(dirname "$(dirname "${matches[0]}")")")
  if [ "$host_system" != "$SYSTEM" ]; then
    die "host '$HOST' is $host_system, but this machine is $SYSTEM"
  fi

  HOST_DIR="$REPO/hosts/$OS-$HOST"
  [ -d "$HOST_DIR" ] || die "missing host directory: ${HOST_DIR#"$REPO"/}"

  info "host:     $HOST ($host_system)"
  info "repo:     $REPO"
}

# --- Nix and git ------------------------------------------------------------

load_nix_profile() {
  if ! command -v nix >/dev/null 2>&1 && [ -r "$NIX_DAEMON_PROFILE" ]; then
    set +u
    # shellcheck source=/dev/null
    . "$NIX_DAEMON_PROFILE"
    set -u
  fi
  command -v nix >/dev/null 2>&1
}

ensure_nix() {
  step "Nix"
  if load_nix_profile; then
    info "found $(nix --version)"
    return
  fi
  [ "$OS" = darwin ] || die "nix not found on NixOS; is PATH set up correctly?"

  info "installing upstream Nix with the Determinate Systems installer"
  local args=(install --prefer-upstream-nix)
  [ "$ASSUME_YES" = 1 ] && args+=(--no-confirm)
  if [ "$DRY_RUN" = 1 ]; then
    run sh -c "curl -fsSL $NIX_INSTALLER_URL | sh -s -- ${args[*]}"
    die "dry run cannot continue without Nix installed"
  fi
  curl --proto '=https' --tlsv1.2 -sSf -L "$NIX_INSTALLER_URL" | sh -s -- "${args[@]}"
  load_nix_profile || die "Nix was installed but is not on PATH; open a new shell and re-run"
}

# Use the system git when it works, otherwise git from nixpkgs. On macOS,
# /usr/bin/git is a stub until the Command Line Tools are installed.
git_cmd() {
  if [ "$OS" = darwin ] && ! xcode-select -p >/dev/null 2>&1; then
    nix run nixpkgs#git -- "$@"
  elif command -v git >/dev/null 2>&1; then
    git "$@"
  else
    nix run nixpkgs#git -- "$@"
  fi
}

# Without a checkout (piped from curl), clone the repo and re-run the copy
# inside it. stdin is reattached to the terminal so prompts from this script,
# disko and nixos-install do not read the rest of the piped script.
ensure_repo() {
  [ -z "$REPO" ] || return 0

  step "Repository"
  if [ -f "$CLONE_DIR/flake.nix" ]; then
    info "using existing checkout at $CLONE_DIR"
  elif [ -e "$CLONE_DIR" ]; then
    die "$CLONE_DIR exists but is not a nix-config checkout"
  else
    ensure_nix
    if [ "$DRY_RUN" = 1 ]; then
      run git clone "$REPO_URL" "$CLONE_DIR"
      die "dry run cannot continue without a checkout"
    fi
    mkdir -p "$(dirname "$CLONE_DIR")"
    run git_cmd clone "$REPO_URL" "$CLONE_DIR"
  fi

  info "re-running from $CLONE_DIR/scripts/bootstrap.sh"
  exec bash "$CLONE_DIR/scripts/bootstrap.sh" "${ORIG_ARGS[@]}" </dev/tty
}

# --- hardware-configuration.nix ---------------------------------------------

# refresh_hardware_config <default y|n> [nixos-generate-config args...]
refresh_hardware_config() {
  local default="$1" file="$HOST_DIR/hardware-configuration.nix" generated
  shift

  step "hardware-configuration.nix"
  if [ ! -f "$file" ]; then
    info "host has no hardware-configuration.nix; skipping"
    return
  fi

  generated=$(sudo nixos-generate-config --show-hardware-config "$@")
  if [ "$generated" = "$(cat "$file")" ]; then
    info "up to date"
    return
  fi

  info "generated config differs from ${file#"$REPO"/}:"
  diff -u --label committed --label generated "$file" - <<<"$generated" >&2 || true
  if confirm "Replace ${file#"$REPO"/} with the generated version?" "$default"; then
    info "writing ${file#"$REPO"/}"
    if [ "$DRY_RUN" = 0 ]; then
      printf '%s\n' "$generated" >"$file"
    fi
    HW_CHANGED=1
  else
    info "keeping the committed version"
  fi
}

# --- nix-darwin -------------------------------------------------------------

darwin_homebrew() {
  step "Homebrew"
  local enabled
  enabled=$(nix eval --json "$REPO#darwinConfigurations.$HOST.config.homebrew.enable")
  if [ "$enabled" != true ]; then
    info "not enabled for $HOST; skipping"
    return
  fi
  if command -v brew >/dev/null 2>&1 || [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ]; then
    info "already installed"
    return
  fi
  info "installing Homebrew (nix-darwin manages packages but not Homebrew itself)"
  if [ "$DRY_RUN" = 1 ]; then
    run bash -c "curl -fsSL $HOMEBREW_INSTALLER_URL | bash"
    return
  fi
  local script
  script=$(curl -fsSL "$HOMEBREW_INSTALLER_URL")
  if [ "$ASSUME_YES" = 1 ]; then
    NONINTERACTIVE=1 bash -c "$script"
  else
    bash -c "$script"
  fi
}

darwin_hostname() {
  step "Hostname"
  # justfile targets .#$(hostname -s), so keep it in sync with the host name.
  local key current
  for key in HostName LocalHostName; do
    current=$(scutil --get "$key" 2>/dev/null || true)
    if [ "$current" = "$HOST" ]; then
      info "$key already $HOST"
    else
      run sudo scutil --set "$key" "$HOST"
    fi
  done
}

# Files the Nix installer edits that nix-darwin's first activation refuses to
# overwrite. Moved aside only for activation; restored if it fails.
DARWIN_ETC_FILES="/etc/bashrc /etc/zshrc /etc/zshenv"
DARWIN_MOVED=""

darwin_move_etc() {
  local f
  for f in $DARWIN_ETC_FILES; do
    [ -e "$f" ] && [ ! -L "$f" ] || continue
    [ ! -e "$f.before-nix-darwin" ] || die "$f.before-nix-darwin already exists; resolve by hand"
    run sudo mv "$f" "$f.before-nix-darwin"
    DARWIN_MOVED="$DARWIN_MOVED $f"
  done
}

darwin_restore_etc() {
  local f
  for f in $DARWIN_MOVED; do
    [ -e "$f" ] || run sudo mv "$f.before-nix-darwin" "$f"
  done
}

darwin_switch() {
  step "darwin-rebuild switch"
  # Use the nix-darwin pinned in flake.lock rather than an unpinned
  # `nix run nix-darwin`, so the first activation matches later rebuilds.
  local dr="<darwin-rebuild>"
  if [ "$DRY_RUN" = 1 ]; then
    run nix build --no-link --print-out-paths --inputs-from "$REPO" nix-darwin#darwin-rebuild
  else
    info "building pinned darwin-rebuild"
    dr=$(nix build --no-link --print-out-paths --inputs-from "$REPO" nix-darwin#darwin-rebuild)
  fi

  darwin_move_etc
  # sudo's secure_path does not include the Nix profile on a fresh Mac.
  if ! run sudo env PATH="/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin" NIX_CONFIG="$NIX_CONFIG" \
    "$dr/bin/darwin-rebuild" switch --flake "$REPO#$HOST"; then
    darwin_restore_etc
    die "darwin-rebuild switch failed"
  fi
}

bootstrap_darwin() {
  darwin_homebrew
  darwin_hostname
  darwin_switch
}

# --- NixOS ------------------------------------------------------------------

bootstrap_nixos() {
  refresh_hardware_config n
  step "nixos-rebuild switch"
  run sudo env NIX_CONFIG="$NIX_CONFIG" nixos-rebuild switch --flake "$REPO#$HOST"
}

install_nixos() {
  local disks="$HOST_DIR/disks.nix" devices dev answer user dest

  is_live_iso || die "--install must be run from the NixOS installer ISO"
  [ -f "$disks" ] || die "--install needs ${disks#"$REPO"/}, which does not exist"

  step "Disks"
  devices=$(nix eval --raw --file "$disks" disko.devices.disk \
    --apply 'd: builtins.concatStringsSep "\n" (map (x: x.device) (builtins.attrValues d))')
  for dev in $devices; do
    [ -e "$dev" ] || die "disk $dev from ${disks#"$REPO"/} is not present"
    lsblk -o NAME,SIZE,TYPE,MODEL,MOUNTPOINTS "$dev" >&2
  done

  printf '\n%sEVERYTHING on the disks above will be erased.%s\n' "$C_RED" "$C_RESET" >&2
  if [ "$DRY_RUN" = 0 ]; then
    read -r -p "    Type the host name ($HOST) to continue: " answer </dev/tty
    [ "$answer" = "$HOST" ] || die "confirmation did not match; nothing was changed"
  fi

  step "disko"
  run sudo env NIX_CONFIG="$NIX_CONFIG" "$(command -v nix)" run "$DISKO_REF" -- \
    --mode destroy,format,mount "$disks"

  # Filesystems are referenced by UUID, which formatting just changed.
  if [ "$DRY_RUN" = 1 ]; then
    step "hardware-configuration.nix"
    info "would regenerate from /mnt after formatting and offer to replace it"
  else
    refresh_hardware_config y --root /mnt
  fi

  step "nixos-install"
  run sudo env NIX_CONFIG="$NIX_CONFIG" nixos-install --flake "$REPO#$HOST"

  step "Copy repository into the new system"
  user=$(nix eval --raw --file "$REPO/variables/default.nix" user.username)
  dest="/home/$user/dev/nix-config"
  if [ -e "/mnt$dest" ]; then
    info "/mnt$dest already exists; skipping"
  else
    run sudo mkdir -p "/mnt$(dirname "$dest")"
    run sudo cp -a "$REPO" "/mnt$dest"
    run sudo nixos-enter --root /mnt -c "chown -R $user: /home/$user/dev"
  fi
}

# --- main -------------------------------------------------------------------

next_steps() {
  step "Done"
  if [ "$HW_CHANGED" = 1 ]; then
    info "hardware-configuration.nix changed; review and commit it:"
    info "  git -C ${1:-$REPO} diff hosts/$OS-$HOST/hardware-configuration.nix"
  fi
  if [ "$INSTALL" = 1 ]; then
    info "Remove the installer media and reboot. The repo is at ~/dev/nix-config."
  else
    info "Open a new shell, then verify with: just check"
  fi
  info "The clone uses HTTPS; to push, switch to SSH:"
  info "  git remote set-url origin git@github.com:b4lisong/nix-config.git"
}

main() {
  parse_args "$@"
  locate_repo

  step "Platform"
  detect_platform
  info "system:   $SYSTEM"
  [ "$INSTALL" = 0 ] || [ "$OS" = linux ] || die "--install is only for NixOS"
  # Root is fine on the installer ISO; elsewhere the repo and Nix profile
  # must belong to the user, and the script calls sudo where needed.
  if [ "$(id -u)" -eq 0 ] && [ "$INSTALL" = 0 ]; then
    die "do not run as root; the script calls sudo where needed"
  fi
  [ "$DRY_RUN" = 0 ] || info "dry run: commands that change the system are printed, not run"

  ensure_repo
  validate_host
  ensure_nix

  if [ "$INSTALL" = 1 ]; then
    install_nixos
    next_steps "/mnt/home/$(nix eval --raw --file "$REPO/variables/default.nix" user.username)/dev/nix-config"
  elif [ "$OS" = darwin ]; then
    bootstrap_darwin
    next_steps
  else
    is_live_iso && die "this is the installer ISO; use --install for a fresh install"
    bootstrap_nixos
    next_steps
  fi
}

main "$@"
