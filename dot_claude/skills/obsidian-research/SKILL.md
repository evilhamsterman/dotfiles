---
name: obsidian-research
description: Save research notes, findings, or investigation results to the Obsidian vault. Use when the user says "save this to Obsidian", "write this up as a research note", "document these findings", "save to Research/", "note this for later in Obsidian", or when summarizing research about a technology, vendor, CVE, tool evaluation, or any topic that should be persisted as a reference note. Also trigger when the user says "remember this" or "document this" in a context that is not about a specific tracked project.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(find *)
  - Bash(grep *)
  - Bash(ls *)
  - Bash(mkdir *)
  - Bash(test *)
  - Bash(date *)
  - Bash(uname *)
  - mcp__claude_ai_Google_Drive__search_files
  - mcp__claude_ai_Google_Drive__read_file_content
  - mcp__claude_ai_Google_Drive__create_file
---

# Obsidian Research Notes Skill

## Vault Path Detection

At the start of every task, run this to determine the vault path:

```bash
test -d "/mnt/g/My Drive/notes" && echo "WSL"
```

- If prints "WSL" → `VAULT="/mnt/g/My Drive/notes"` (WSL with G: drive mounted — primary)
- If on Windows native (Claude Desktop): `uname -s` won't be available or will show a Windows indicator — use `VAULT="G:\My Drive\notes"`
- If neither local path is accessible → use Google Drive MCP fallback (see below)

## Task: Save or Append a Research Note

### Determine the target file

- Derive a topic slug from the user's input: lowercase, spaces replaced with hyphens, no special characters
  - Example: "Kolla Ansible HA Setup" → `kolla-ansible-ha-setup`
- Target: `"$VAULT/Research/<topic-slug>.md"`
- If the user specifies the topic name, use it directly (normalized). If not, infer from content.
- Create the `Research/` directory if it does not exist: `mkdir -p "$VAULT/Research"`

### If the file does NOT exist — Create it

Write this template (substitute all `<PLACEHOLDER>` values):

```markdown
# <Title>

**Date:** <YYYY-MM-DD>
**Tags:** #research <additional-tags>

## Summary
<2-3 sentences capturing the core finding or purpose of this research>

## Findings

<Main content here>

## Sources
<List any URLs, docs, or references — use plain markdown links>

## Related Projects
<Obsidian wiki links to relevant projects, e.g. [[Staq/Staq]] — omit section if none>

## Open Questions
-
```

- Get today's date: `date +%Y-%m-%d`
- Infer additional tags from content (e.g. `#openstack #networking #security`) — lowercase, hyphens for multi-word
- If the user provided raw content (a wall of text, conversation excerpt), distill it: extract key findings, decisions, open questions rather than dumping verbatim

### If the file ALREADY exists — Append to it

- Read the existing file first
- Append at the bottom:

```markdown

---

## Update — <YYYY-MM-DD>

<New content>
```

Do NOT modify or rewrite existing content — append only.

### After writing

Tell the user:
- Full path written to
- Whether it was a new file or an update
- Scan `$VAULT/Projects/` for any project names matching the topic and mention them as related

## MCP Fallback (Google Drive)

If no local vault path is accessible:

1. Search for the Research folder: `mcp__claude_ai_Google_Drive__search_files` with query `name contains "Research" and mimeType = "application/vnd.google-apps.folder"`
2. If the file exists, read it: `mcp__claude_ai_Google_Drive__read_file_content`
3. To create or update: `mcp__claude_ai_Google_Drive__create_file` — **always specify `mimeType: text/plain`** so the file is stored as plain Markdown, not a Google Doc. Without this, Drive creates a Google Doc that Obsidian cannot sync correctly.
4. Tell the user the MCP path was used.

## Quality Standard

Research notes should be useful when read 6 months later by someone unfamiliar with the original context. Always include a Summary — never just dump raw content.
