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

At the start of every task, run these checks in order and use the first path that exists:

```bash
test -d "$HOME/Documents/notes" && echo "RCLONE"
test -d "/mnt/g/My Drive/notes" && echo "WSL"
```

1. `$HOME/Documents/notes` exists → `VAULT="$HOME/Documents/notes"` (rclone mount — primary)
2. `/mnt/g/My Drive/notes` exists → `VAULT="/mnt/g/My Drive/notes"` (WSL with G: mounted)
3. Windows native (Claude Desktop, no WSL paths) → `VAULT="G:\My Drive\notes"`
4. None of the above → Google Drive MCP fallback (see below)

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

**Always use these parameters when calling `create_file`:**
- `contentMimeType: "text/plain"`
- `disableConversionToGoogleType: true`
- `parentId: <folder-id>`

Both flags are required. Without `disableConversionToGoogleType`, Drive silently converts `text/plain` to a Google Doc that Obsidian cannot sync as Markdown.

**Step-by-step:**

1. Find the Research folder ID: search with `title = 'Research' and mimeType = 'application/vnd.google-apps.folder'`
2. Search for an existing note: `title = '<topic-slug>.md' and '<folder-id>' in parents`
3. If the file exists:
   - Read it with `mcp__claude_ai_Google_Drive__read_file_content`
   - Build the full updated content (append new section)
   - Create a new file with the same name, `contentMimeType: text/plain`, `disableConversionToGoogleType: true`, `parentId`
   - Tell the user: "Old file ID: `<id>` — trash it in Google Drive to remove the duplicate"
4. If the file does not exist: create it directly with the template content
5. Tell the user the MCP path was used

## Quality Standard

Research notes should be useful when read 6 months later by someone unfamiliar with the original context. Always include a Summary — never just dump raw content.
