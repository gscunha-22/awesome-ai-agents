#!/usr/bin/env bash
# Proves each installed agent actually executes (import + CLI where one exists).
# Exit code is non-zero if any check fails. Network access is not required.
set -uo pipefail

AGENTS_HOME="${AGENTS_HOME:-$HOME/.awesome-ai-agents}"
pass=0; fail=0

check() {
  local name="$1"; shift
  if out=$("$@" 2>&1); then
    printf '  \033[1;32mOK\033[0m   %-16s %s\n' "$name" "$(printf '%s' "$out" | tail -n1 | cut -c1-90)"
    pass=$((pass+1))
  else
    printf '  \033[1;31mFAIL\033[0m %-16s %s\n' "$name" "$(printf '%s' "$out" | tail -n3 | tr '\n' ' ' | cut -c1-200)"
    fail=$((fail+1))
  fi
}

py() { echo "$AGENTS_HOME/$1/bin/python"; }

echo "Verifying agents under $AGENTS_HOME"

[[ -x "$(py aider)" ]] && check aider "$AGENTS_HOME/aider/bin/aider" --version
[[ -x "$(py crewai)" ]] && check crewai "$AGENTS_HOME/crewai/bin/crewai" version
[[ -x "$(py gpt-researcher)" ]] && check gpt-researcher "$(py gpt-researcher)" -c \
  'import gpt_researcher, importlib.metadata as m; from gpt_researcher import GPTResearcher; print("gpt-researcher", m.version("gpt-researcher"))'
[[ -x "$(py open-interpreter)" ]] && check open-interpreter "$AGENTS_HOME/open-interpreter/bin/interpreter" --version
[[ -x "$(py vanna)" ]] && check vanna "$(py vanna)" -c \
  'import importlib.metadata as m; from vanna import Agent; from vanna.tools import RunSqlTool; from vanna.integrations.postgres import PostgresRunner; print("vanna", m.version("vanna"), "+ PostgresRunner")'

echo
echo "passed=$pass failed=$fail"
[[ $fail -eq 0 ]]
