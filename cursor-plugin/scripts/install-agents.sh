#!/usr/bin/env bash
# Installs the open-source agents from awesome-ai-agents that were selected for
# the connector-driven workflows (see ../AGENT-MAPPING.md).
#
# Each agent lives in its own virtualenv under $AGENTS_HOME so dependency trees
# never collide. Re-running is idempotent.
#
# Usage:
#   ./install-agents.sh            # install every agent
#   ./install-agents.sh aider vanna # install a subset
#   AGENTS_HOME=/opt/agents ./install-agents.sh
set -euo pipefail

AGENTS_HOME="${AGENTS_HOME:-$HOME/.awesome-ai-agents}"
PYTHON="${PYTHON:-python3}"
# uv defaults to "managed" interpreters once it has downloaded one, which would
# silently switch later venvs to a different Python. Pin the default explicitly.
PYTHON_DEFAULT="${PYTHON_DEFAULT:-3.12}"

# name -> pip spec(s), space separated. Keep alphabetical.
# - gpt-researcher 0.16.0 ships a broken module (missing `typing` import in
#   actions/query_processing.py), so pin the last importable release.
# - open-interpreter 0.4.x imports pkg_resources; uv venvs have no setuptools
#   and setuptools>=81 dropped pkg_resources, so pin below that.
declare -A SPECS=(
  [aider]="aider-chat"
  [crewai]="crewai"
  [gpt-researcher]="gpt-researcher==0.15.1"
  [open-interpreter]="open-interpreter setuptools<81"
  [vanna]="vanna[postgres]"
)

# Per-agent interpreter override when the newest release drops a Python.
declare -A PYTHON_FOR=(
  [open-interpreter]="3.11"
)

log() { printf '\033[1;34m[install-agents]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[install-agents]\033[0m %s\n' "$*" >&2; exit 1; }

ensure_uv() {
  if command -v uv >/dev/null 2>&1; then return; fi
  log "uv not found; installing with pip --user"
  "$PYTHON" -m pip install --user --quiet uv || die "could not install uv"
  export PATH="$HOME/.local/bin:$PATH"
  command -v uv >/dev/null 2>&1 || die "uv still not on PATH after install"
}

install_one() {
  local name="$1" spec="${SPECS[$1]}" venv="$AGENTS_HOME/$1"
  local py="${PYTHON_FOR[$name]:-$PYTHON_DEFAULT}"
  log "==> $name  ($spec, python $py)  -> $venv"
  # `set -e` is suspended inside `if ! install_one`, so fail explicitly.
  uv venv --quiet --clear --python "$py" "$venv" || return 1
  # shellcheck disable=SC2086  # intentional word-splitting of multi-spec entries
  uv pip install --quiet --python "$venv/bin/python" $spec || return 1
  log "    installed $name"
}

main() {
  ensure_uv
  mkdir -p "$AGENTS_HOME"

  local targets=("$@")
  if [[ ${#targets[@]} -eq 0 ]]; then
    targets=($(printf '%s\n' "${!SPECS[@]}" | sort))
  fi

  local failed=()
  for t in "${targets[@]}"; do
    [[ -n "${SPECS[$t]:-}" ]] || die "unknown agent '$t' (known: ${!SPECS[*]})"
    if ! install_one "$t"; then failed+=("$t"); fi
  done

  # Convenience shims so the CLIs are reachable without activating a venv.
  mkdir -p "$AGENTS_HOME/bin"
  for cli in aider crewai interpreter; do
    for t in "${targets[@]}"; do
      if [[ -x "$AGENTS_HOME/$t/bin/$cli" ]]; then
        ln -sf "$AGENTS_HOME/$t/bin/$cli" "$AGENTS_HOME/bin/$cli"
      fi
    done
  done

  if [[ ${#failed[@]} -gt 0 ]]; then
    die "failed: ${failed[*]}"
  fi
  log "all done. Add to PATH:  export PATH=\"$AGENTS_HOME/bin:\$PATH\""
  log "verify with:            $(dirname "$0")/verify-agents.sh"
}

main "$@"
