---
name: installed-agents
description: How to invoke the open-source agents installed by awesome-ai-agents-workflows (Aider, CrewAI, GPT Researcher, Open Interpreter, Vanna.AI) - paths, required environment variables, and the one-line health check. Use before shelling out to any of these agents.
---

# Installed agents

`scripts/install-agents.sh` installs each agent into its own virtualenv under
`$AGENTS_HOME` (default `~/.awesome-ai-agents`). Nothing is on `PATH` until
you add the shim directory:

```bash
export PATH="$HOME/.awesome-ai-agents/bin:$PATH"
```

| Agent | Invoke | Needs | Role in this plugin |
| --- | --- | --- | --- |
| Aider | `aider --model <provider/model> --yes-always -m "<task>" <files>` | one LLM key: `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, ... | repo-wide edits for `deploy-engineer` |
| CrewAI | `crewai create crew <name> --classic --skip-provider`, then `crewai run` inside the project | LLM key; `crewai run` reads `.env` in the project | pipelines for `workflow-orchestrator` |
| GPT Researcher | `~/.awesome-ai-agents/gpt-researcher/bin/python -c 'from gpt_researcher import GPTResearcher; ...'` (async API, see `knowledge-researcher`) | `OPENAI_API_KEY` (or another provider via `FAST_LLM`/`SMART_LLM=<provider>:<model>`), plus a retriever key such as `TAVILY_API_KEY` (`RETRIEVER` selects it); optional `SCRAPER=firecrawl` with `FIRECRAWL_API_KEY` | deep research for `knowledge-researcher` and `web-data-collector` |
| Open Interpreter | `interpreter -y --model <model>` or `interpreter -y -m "<task>"`-style prompts via stdin | LLM key | executes generated scripts for `deploy-engineer` and data fixes |
| Vanna.AI | `~/.awesome-ai-agents/vanna/bin/python <script>` (library; see `sql-data-analyst` for the Agent wiring) | LLM key and `DATABASE_URL` (Supabase/Neon Postgres connection string) | text-to-SQL for `sql-data-analyst` |

## Health check

```bash
cursor-plugin/scripts/verify-agents.sh   # exit 0 when all five import/run
```

If an agent is missing, reinstall just that one:

```bash
cursor-plugin/scripts/install-agents.sh vanna
```

## Rules of thumb

- Never echo API keys or connection strings into chat or files. Read them
  from the environment; if absent, name the variable and stop.
- Prefer Cursor's own editing tools for small changes; reach for Aider when
  the change spans many files or needs its own commit history.
- Each agent has its own interpreter (`$AGENTS_HOME/<agent>/bin/python`).
  Do not `pip install` into the system Python to satisfy an agent.
- Known pins (see `install-agents.sh`): `gpt-researcher==0.15.1` because
  0.16.0 fails to import; `setuptools<81` in the Open Interpreter venv
  because newer setuptools dropped `pkg_resources`.
