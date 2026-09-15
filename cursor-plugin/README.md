# Awesome AI Agents - Connector Workflows (Cursor plugin)

A Cursor plugin that imports the agents from this list that best fit the
connectors a user already has active in Cursor, and installs the open-source
ones so they can actually run.

The selection is derived from observed connectors, not guesses. The full
connector -> activity -> agent analysis is in [`AGENT-MAPPING.md`](AGENT-MAPPING.md).

## What you get

| Component | Contents |
| --- | --- |
| `agents/` | 6 subagents, one per mapped activity: `inbox-calendar-assistant`, `knowledge-researcher`, `sql-data-analyst`, `deploy-engineer`, `web-data-collector`, `workflow-orchestrator`. Each says which connectors and which installed agent it drives. |
| `skills/installed-agents/` | How to invoke Aider, CrewAI, GPT Researcher, Open Interpreter and Vanna.AI from their venvs, with required env vars. |
| `commands/` | `/agents-install` and `/agents-verify`. |
| `scripts/install-agents.sh` | Idempotent installer (one `uv` venv per agent under `~/.awesome-ai-agents`). |
| `scripts/verify-agents.sh` | Offline health check; exit 0 when every agent imports/runs. |

## Install

### Plugin (Cursor)

```bash
git clone https://github.com/e2b-dev/awesome-ai-agents
mkdir -p ~/.cursor/plugins/local
ln -s "$(pwd)/awesome-ai-agents/cursor-plugin" ~/.cursor/plugins/local/awesome-ai-agents-workflows
```

Fully quit and relaunch Cursor. The six subagents appear in the Task tool
list and the two commands are available as `/agents-install` and
`/agents-verify`.

Alternatively copy `agents/*.md` into a project's `.cursor/agents/` if you
only want the subagents for one repository.

### Open-source agents

```bash
cursor-plugin/scripts/install-agents.sh
cursor-plugin/scripts/verify-agents.sh
export PATH="$HOME/.awesome-ai-agents/bin:$PATH"
```

Requires `python3` (3.12 by default; the installer downloads 3.11 via `uv`
for Open Interpreter) and network access to PyPI. Roughly 2 GB of disk.

## Connectors this plugin expects

Authenticated MCP servers or installed plugins for some subset of: Gmail,
Google Calendar, Outlook Calendar, Slack, Notion, Google Drive, Granola,
Mem0, Supabase, Neon, Atlan, Vercel, Netlify, Grafana Cloud, Bright Data,
Apify, Firecrawl, Context.dev. Each subagent degrades gracefully when a
connector reports `needsAuth`: it asks for `mcp_auth` and continues with the
others.

## API keys

The installed agents call LLMs directly and need at least one provider key
(`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, ...). GPT Researcher also needs a
retriever key (`TAVILY_API_KEY`) unless you route scraping through Firecrawl
or Bright Data. Vanna needs `DATABASE_URL`. None of these are stored by the
plugin.

## Layout

```
cursor-plugin/
├── .cursor-plugin/plugin.json
├── AGENT-MAPPING.md
├── README.md
├── agents/
│   ├── deploy-engineer.md
│   ├── inbox-calendar-assistant.md
│   ├── knowledge-researcher.md
│   ├── sql-data-analyst.md
│   ├── web-data-collector.md
│   └── workflow-orchestrator.md
├── commands/
│   ├── agents-install.md
│   └── agents-verify.md
├── scripts/
│   ├── install-agents.sh
│   └── verify-agents.sh
└── skills/
    └── installed-agents/SKILL.md
```
