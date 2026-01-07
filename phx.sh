#!/usr/bin/env bash

# phx - PHP Version Manager
# Manages system-installed PHP versions (apt, etc.)

set -euo pipefail

# --- Visual helpers ---
C_RESET="\033[0m"
C_RED="\033[0;31m"
C_GREEN="\033[0;32m"
C_BLUE="\033[0;34m"

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

  [[ "$version" == "system" || -z "$version" ]] && return 0

  for bin_path in "${PHX_BIN_PATHS[@]}"; do
    [[ -d "$bin_path" ]] || continue

    while IFS= read -r -d $'\0' bin; do
      found_binaries+=("$bin")
    done < <(find "$bin_path" -maxdepth 1 -type f -executable -name "*${version}" -print0)
  done

  [[ ${#found_binaries[@]} -gt 0 ]] || err "PHP $version not found"

  for bin in "${found_binaries[@]}"; do
    local base
    base=$(basename "$bin")

    [[ "$base" =~ ^(php|phar|php-cgi|php-fpm|php-config|phpize|phpdbg|php-cli) ]] || continue
    ln -sf "$bin" "$SHIMS_DIR/${base%$version}"
  done

  [[ "$quiet" == "true" ]] || msg "Using PHP $version"
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
      echo '  PROMPT_COMMAND="phx_auto_switcher${PROMPT_COMMAND:+; $PROMPT_COMMAND}"'
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
  [[ "${PHX_ACTIVE_VERSION:-system}" == "system" ]] &&
    msg "Using system PHP" ||
    msg "Active PHP: ${C_GREEN}$PHX_ACTIVE_VERSION${C_RESET}"
  php -v
}

cmd_which() {
  [[ -L "$SHIMS_DIR/php" ]] &&
    msg "php → $(readlink -f "$SHIMS_DIR/php")" ||
    msg "php → $(command -v php)"
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
  __auto_switcher) phx_auto_switcher ;;
  help | -h | --help) cmd_help ;;
  *) err "Unknown command: $cmd" ;;
  esac
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
