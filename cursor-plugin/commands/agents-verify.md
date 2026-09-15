---
name: agents-verify
description: Check that every agent installed by awesome-ai-agents-workflows still imports and runs, and report versions.
---

# agents-verify

Run `scripts/verify-agents.sh` from this plugin with `bash` and present the
result as a table of agent, status and version. The script exits non-zero if
any agent fails; in that case quote the failure line and offer to run
`/agents-install <agent>` for the broken one.

Do not attempt network calls or LLM requests; the verifier is offline by
design.
