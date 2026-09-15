# Connector -> activity -> agent mapping

This document records how the agents bundled by this plugin were chosen. The
input was the set of connectors active in the user's Cursor environment; the
output is the shortlist of agents from the main [README](../README.md) that
add the most value to the activities those connectors imply.

## 1. Active connectors (observed)

| Connector | Type | Status when audited | Signal |
| --- | --- | --- | --- |
| Gmail | MCP (32 tools) | authenticated | email triage, drafting, labels, filters |
| Google Calendar | MCP (10 tools) | authenticated | scheduling, availability, event search |
| Outlook Calendar | MCP | installed, needs auth | second calendar (work/personal split) |
| Slack | plugin (skills, no MCP) | installed | team messaging, Block Kit, Slack apps |
| Notion | MCP (44 tools) | authenticated | docs, databases, meeting notes, tasks, custom agents |
| Google Drive | MCP (12 tools) | authenticated | file storage, docs, sharing |
| Granola | MCP + plugin | installed, needs auth | meeting transcripts and decisions |
| Mem0 | MCP (stdio) | installed, loading | long-term memory across sessions |
| Supabase | MCP (30 tools) | authenticated | Postgres, migrations, edge functions, logs, advisors |
| Neon | MCP | installed, needs auth | serverless Postgres, branches |
| Atlan | MCP | installed, needs auth | data catalog, lineage, glossary |
| Vercel | MCP + plugin (skills, 3 agents) | installed, needs auth | Next.js/AI SDK apps, deploys, env vars |
| Netlify | plugin (skills only) | installed | functions, edge, blobs, DB, deploys |
| Grafana Cloud | MCP + plugin | installed, needs auth | dashboards, Prometheus/Loki, alerting, incidents |
| Bright Data | MCP + plugin (agent, commands) | installed, loading | SERP, web unlocker, structured web data |
| Apify | MCP + plugin (agent) | installed, needs auth | actors, scraping at scale |
| Firecrawl | plugin (skills, CLI) | installed | crawl/scrape/search/map |
| Context.dev | MCP + plugin | installed, needs auth | live web search, extraction, monitoring, batches |

Cursor-native tooling (`cursor`, `cursor-cloud`, `cursor-subscriptions`) and
the `create-plugin` / `agent-compatibility` plugins were treated as
infrastructure, not usage signal.

## 2. Usage pattern derived from the connectors

The connectors cluster into six activities. Each row is what the user is
evidently doing, inferred only from what is installed and authenticated.

| # | Activity | Evidence (connectors) | Weight |
| --- | --- | --- | --- |
| A | **Communication and scheduling** - inbox triage, replies, follow-ups, finding meeting slots across two calendars, posting to Slack | Gmail, Google Calendar, Outlook Calendar, Slack | high (3 authenticated/installed comms tools) |
| B | **Knowledge, meetings and memory** - writing and retrieving docs, turning meeting decisions into tasks, keeping durable context | Notion, Google Drive, Granola, Mem0 | high (Notion is the largest authenticated surface: 44 tools) |
| C | **Data and databases** - querying Postgres, schema work, understanding datasets, governance | Supabase, Neon, Atlan | high (Supabase authenticated with SQL/migration/log tools) |
| D | **Building, deploying and operating web apps** - full-stack TypeScript/Python work, deploys, env vars, observability | Vercel, Netlify, Supabase (edge functions), Grafana Cloud | high (two hosting platforms + monitoring) |
| E | **Web data collection and research** - search, scrape, extract structured data, monitor pages | Bright Data, Apify, Firecrawl, Context.dev | medium-high (four overlapping scraping stacks) |
| F | **Cross-tool orchestration** - chaining the above into repeatable multi-step workflows | all of the above; Notion custom agents/sessions; Cursor subagents | implied by breadth |

Profile: a builder/operator who ships web apps on Vercel/Netlify backed by
Postgres, runs research and data collection from the web, and manages the
surrounding business workflow (email, calendar, Notion, meetings) from the
same IDE.

## 3. Agent selection

Selection criteria, in order:

1. **Fit** - the agent's category in the README matches the activity.
2. **Composability** - it can be driven from Cursor and combined with the
   connector's MCP tools (CLI or Python library beats a closed SaaS UI).
3. **Installability** - open source and `pip`-installable so it can actually
   be installed and verified here. Closed-source products are listed as
   optional complements, not installed.
4. **Non-duplication** - skip agents whose job a connector already does
   natively (e.g. Mem0 already provides memory, so MemGPT/Letta is not
   installed).

### Installed (open source, verified by `scripts/verify-agents.sh`)

| Activity | Agent (README entry) | README category | Why it wins for this activity | Pip spec |
| --- | --- | --- | --- | --- |
| D | [Aider](https://github.com/paul-gauthier/aider) | Coding, GitHub | Repo-aware CLI pair programmer; edits the local checkout that Vercel/Netlify deploy from, works with git so PRs stay reviewable | `aider-chat` |
| C | [Vanna.AI](https://vanna.ai/) | Data analysis, Coding | Text-to-SQL agent trained on your own schema; ships a `PostgresRunner` that points straight at Supabase/Neon | `vanna[postgres]` |
| B, E | [GPT Researcher](https://github.com/assafelovic/gpt-researcher) | Research, Science | Autonomous multi-source research producing cited reports; output drops naturally into Notion/Drive; scraper backends can be swapped for Firecrawl/Bright Data | `gpt-researcher==0.15.1` (0.16.0 is not importable) |
| D, C | [Open Interpreter](https://openinterpreter.com/) | Coding | Runs generated code locally for ad-hoc data wrangling, log analysis and ops scripts against Supabase/Grafana exports | `open-interpreter` + `setuptools<81` |
| F | [CrewAI](https://github.com/joaomdmoura/crewai) | Build-your-own, Multi-agent | Role-based crews to chain research -> SQL -> doc -> email steps; the framework for turning the other agents into repeatable workflows | `crewai` |

### Imported as Cursor subagents (no install needed; use connector MCP tools directly)

| Activity | Subagent file | Modelled on (README) | Connectors used |
| --- | --- | --- | --- |
| A | `agents/inbox-calendar-assistant.md` | Lindy, AgentScale, Floode, Heymoon.ai, Cal.ai | Gmail, Google Calendar, Outlook Calendar, Slack skills |
| B | `agents/knowledge-researcher.md` | GPT Researcher, Private GPT / Local GPT | Notion, Google Drive, Granola, Mem0 + installed `gpt-researcher` |
| C | `agents/sql-data-analyst.md` | Vanna.AI, Wren, BambooAI, AskYourDatabase, Dot | Supabase, Neon, Atlan + installed `vanna` |
| D | `agents/deploy-engineer.md` | Aider, Sweep, Dosu, Continue, v0 by Vercel | Vercel, Netlify skills, Supabase, Grafana Cloud + installed `aider`, `interpreter` |
| E | `agents/web-data-collector.md` | GPT Researcher, Kadoa, Claygent, Self-operating computer | Bright Data, Apify, Firecrawl, Context.dev + installed `gpt-researcher` |
| F | `agents/workflow-orchestrator.md` | CrewAI, AutoGen, Langroid, Zapier Central, Gumloop | all connectors + installed `crewai` |

### Considered and not installed

| Agent | Reason |
| --- | --- |
| MemGPT / Letta | memory is already provided by the Mem0 connector |
| Wren AI | Docker-based service, heavier than Vanna for the same text-to-SQL job |
| Private GPT, Local GPT | require local LLM weights; Notion/Drive MCP already give document access |
| OpenDevin / OpenHands, SWE-agent, Devika | Docker/sandbox-first; Aider covers the repo-editing need from the CLI |
| AutoGen, Langroid | equivalent to CrewAI; one orchestration framework is enough |
| Lindy, Julius, Dosu, Sweep, Kadoa, Claygent, Zapier Central, Gumloop | closed-source SaaS; listed as complements in the subagent prompts, cannot be installed or verified here |
| Cal.ai | requires a Cal.com deployment; Calendar MCP tools cover scheduling |

## 4. Verification evidence

Run from the repository root:

```bash
cursor-plugin/scripts/install-agents.sh   # creates ~/.awesome-ai-agents/<agent> venvs
cursor-plugin/scripts/verify-agents.sh    # imports/CLIs each agent, exit 0 on success
```

Expected output of the verifier (versions will drift over time):

```
Verifying agents under /home/<user>/.awesome-ai-agents
  OK   aider            aider 0.86.2
  OK   crewai           crewai version: 1.15.21
  OK   gpt-researcher   gpt-researcher 0.15.1
  OK   open-interpreter Open Interpreter 0.4.3 Developer Preview
  OK   vanna            vanna 2.0.2 + PostgresRunner

passed=5 failed=0
```
