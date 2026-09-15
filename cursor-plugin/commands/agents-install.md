---
name: agents-install
description: Install (or reinstall) the open-source agents selected for the user's connectors - Aider, CrewAI, GPT Researcher, Open Interpreter and Vanna.AI - into isolated virtualenvs.
---

# agents-install

Run the plugin's installer and report the result.

1. Locate `scripts/install-agents.sh` in this plugin (next to this file's
   parent directory). Run it with `bash`. Optional arguments are agent names
   to install a subset (`aider`, `crewai`, `gpt-researcher`,
   `open-interpreter`, `vanna`).
2. It needs `python3` and will install `uv` with `pip --user` if it is not
   already present. Each agent lands in `~/.awesome-ai-agents/<agent>`;
   override with `AGENTS_HOME=<dir>`.
3. When it finishes, run `scripts/verify-agents.sh` and show the table.
4. Remind the user to add `~/.awesome-ai-agents/bin` to `PATH` and which API
   keys each agent needs (see the `installed-agents` skill).

If installation fails for one agent, show the last lines of the error, keep
the others, and suggest rerunning with just that agent's name.
