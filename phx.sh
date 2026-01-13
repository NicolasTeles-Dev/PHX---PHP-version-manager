#!/usr/bin/env bash

# phx - PHP Version Manager
# Manages system-installed PHP versions (apt, etc.)

set -euo pipefail

# --- Version ---
PHX_VERSION="0.2.1-b0"

# --- Visual helpers ---
C_RESET="\033[0m"
C_RED="\033[0;31m"
C_GREEN="\033[0;32m"
C_BLUE="\033[0;34m"

if [[ -n "${NO_COLOR:-}" || "${TERM:-}" == "dumb" ]]; then
  C_RESET=""
  C_RED=""
  C_GREEN=""
  C_BLUE=""
fi

msg() { echo -e "${C_BLUE}phx:${C_RESET} $1"; }
err() {
  echo -e "${C_RED}phx: [ERROR]${C_RESET} $1" >&2
  exit 1
}

# --- Paths ---
: "${PHX_DIR:=$HOME/.phx}"

SHIMS_DIR="$PHX_DIR/shims"
GLOBAL_VERSION_FILE="$PHX_DIR/version"

: "${PHX_BIN_PATHS_DEFAULT:=/usr/bin}"
IFS=' ' read -r -a PHX_BIN_PATHS <<<"$PHX_BIN_PATHS_DEFAULT"

export PHX_DIR

# --- Core logic ---

phx_list_all_versions() {
  local versions=()

  for bin_path in "${PHX_BIN_PATHS[@]}"; do
    [[ -d "$bin_path" ]] || continue

    for bin in "$bin_path"/php[0-9]*.[0-9]*; do
      [[ -x "$bin" ]] || continue
      versions+=("$(basename "$bin" | sed 's/^php//')")
    done
  done

  printf "%s\n" "${versions[@]}" | sort -rV | uniq
}

phx_rehash() {
  local version="${1:-system}"
  local quiet="${2:-false}"
  local found_binaries=()

  rm -rf "$SHIMS_DIR"
  mkdir -p "$SHIMS_DIR"

  if [[ "$version" == "system" || -z "$version" ]]; then
    if ! [[ "$quiet" == "true" ]]; then
      msg "Using system PHP"
    fi
    return 0
  fi

  local php_bin
  for bin_path in "${PHX_BIN_PATHS[@]}"; do
    if [[ -x "$bin_path/php$version" ]]; then
      php_bin="$bin_path/php$version"
      break
    fi
  done

  [[ -n "$php_bin" ]] || err "PHP $version not found"

  local bins_to_shim=(
    "php" "phar" "php-cgi" "php-fpm" "php-config" "phpize" "phpdbg"
  )

  for bin_name in "${bins_to_shim[@]}"; do
    for bin_path in "${PHX_BIN_PATHS[@]}"; do
      if [[ -x "$bin_path/$bin_name$version" ]]; then
        ln -sf "$bin_path/$bin_name$version" "$SHIMS_DIR/$bin_name"
        break
      fi
    done
  done

  if ! [[ "$quiet" == "true" ]]; then
    msg "Using PHP $version"
  fi
}

phx_find_local_version() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/.phx-version" ]] && cat "$dir/.phx-version" && return 0
    dir=$(dirname "$dir")
  done
  return 1
}

phx_auto_switcher() {
  local version

  if version=$(phx_find_local_version 2>/dev/null); then
    :
  elif [[ -f "$GLOBAL_VERSION_FILE" ]]; then
    version=$(cat "$GLOBAL_VERSION_FILE")
  else
    version="system"
  fi

  [[ "${PHX_ACTIVE_VERSION:-}" == "$version" ]] && return 0

  export PHX_ACTIVE_VERSION="$version"
  phx_rehash "$version" true >/dev/null 2>&1 || true
}

# --- Commands ---

cmd_init() {
  if [[ "${1:-}" == "-" ]]; then
    echo "export PHX_DIR=\"$PHX_DIR\""
    echo "export PATH=\"$SHIMS_DIR:\$PATH\""

    case "$(basename "$SHELL")" in
    bash)
      echo 'phx_auto_switcher() { command phx __auto_switcher; }'
      echo 'if [[ -z "${PHX_HOOKED:-}" ]]; then'
      echo '  export PHX_HOOKED=1'
      echo '  PROMPT_COMMAND="phx_auto_switcher${PROMPT_COMMAND:+\; $PROMPT_COMMAND}"'
      echo 'fi'
      ;;
    zsh)
      echo 'phx_auto_switcher() { command phx __auto_switcher; }'
      echo 'autoload -Uz add-zsh-hook'
      echo 'if [[ -z "${PHX_HOOKED:-}" ]]; then'
      echo '  export PHX_HOOKED=1'
      echo '  add-zsh-hook precmd phx_auto_switcher'
      echo 'fi'
      ;;
    *)
      echo '# Shell not supported for auto switch'
      ;;
    esac
    return
  fi

  mkdir -p "$PHX_DIR" "$SHIMS_DIR"
  touch "$GLOBAL_VERSION_FILE"
  msg "PHX installed on $PHX_DIR"
}

cmd_list() {
  msg "Available PHP versions:"
  for v in $(phx_list_all_versions); do
    [[ "${PHX_ACTIVE_VERSION:-}" == "$v" ]] &&
      echo -e "  ${C_GREEN}* $v${C_RESET}" ||
      echo "    $v"
  done
}

cmd_global() {
  local v="${1:-}"
  [[ -z "$v" ]] && err "Usage: phx global <version>"
  phx_list_all_versions | grep -qx "$v" || err "PHP $v not installed"

  echo "$v" >"$GLOBAL_VERSION_FILE"
  phx_auto_switcher
}

cmd_local() {
  local v="${1:-}"
  [[ -z "$v" ]] && err "Usage: phx local <version>"
  phx_list_all_versions | grep -qx "$v" || err "PHP $v not installed"

  echo "$v" >.phx-version
  phx_auto_switcher
}

cmd_current() {
  local version
  if version=$(phx_find_local_version 2>/dev/null); then
    :
  elif [[ -f "$GLOBAL_VERSION_FILE" ]]; then
    version=$(cat "$GLOBAL_VERSION_FILE")
  else
    version="system"
  fi

  [[ "$version" == "system" ]] &&
    msg "Using system PHP" ||
    msg "Active PHP: ${C_GREEN}$version${C_RESET}"
  php -v
}

cmd_which() {
  [[ -L "$SHIMS_DIR/php" ]] &&
    msg "php → $(readlink -f "$SHIMS_DIR/php")" ||
    msg "php → $(command -v php)"
}

cmd_version() {
  echo "phx $PHX_VERSION"
}

cmd_help() {
  cat <<EOF
phx - PHP Version Manager

Commands:
  init
  list
  global <versão>
  local <versão>
  current
  which
  version
EOF
}

# --- Dispatcher ---

main() {
  local cmd="${1:-help}"
  shift || true

  case "$cmd" in
  init) cmd_init "$@" ;;
  list) cmd_list ;;
  global) cmd_global "$@" ;;
  local) cmd_local "$@" ;;
  current) cmd_current ;;
  which) cmd_which ;;
  version) cmd_version ;;
  __auto_switcher) phx_auto_switcher ;;
  help | -h | --help) cmd_help ;;
  *) err "Unknown command: $cmd" ;;
  esac
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
