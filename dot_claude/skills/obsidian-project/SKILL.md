---
name: obsidian-project
description: Scaffold a new project note in the Obsidian vault and register it in the Projects Index. Use when the user says "create a new project", "add project to Obsidian", "start tracking this project", "scaffold a project note", "new project note for X", or when beginning work on something that needs long-term tracking in the vault. Do NOT use this to update an existing project — use obsidian-update for that.
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
  - mcp__claude_ai_Google_Drive__download_file_content
---

# Obsidian Project Scaffolding Skill

## Vault Path Detection

```bash
test -d "/mnt/g/My Drive/notes" && echo "WSL"
```

- Prints "WSL" → `VAULT="/mnt/g/My Drive/notes"` (primary)
- Windows native (Claude Desktop, no `/mnt/g`) → `VAULT="G:\My Drive\notes"`
- Neither accessible → Google Drive MCP fallback (see below)

## Task: Create a New Project Note

### Step 1 — Collect information

Gather the following — ask if not provided, but extract from natural language first:

- **Project name** — used as directory and filename: `Title-Case-With-Hyphens` format (e.g. `K3s-Cluster-Migration`)
- **Subtitle** — one line description
- **Priority** — Critical / High / Active / Long-term / Blocked / Ongoing
- **Phase** — Planning / PoC / Implementation / Testing / Production / Ongoing
- **Blocked by** — what's blocking progress, or "Nothing currently"
- **Overview** — 2-4 sentences: what is it, why does it exist, what's the goal
- **Initial next actions** — at least one concrete task

### Step 2 — Check for existing project

Before creating, check:
```bash
ls "$VAULT/Projects/" | grep -i "<ProjectName>"
```

If a match exists, read that project's note and tell the user — do NOT overwrite. Offer to use `obsidian-update` instead.

### Step 3 — Create the project directory and note

```bash
mkdir -p "$VAULT/Projects/<ProjectName>"
```

Write `"$VAULT/Projects/<ProjectName>/<ProjectName>.md"` using this template:

```markdown
# <ProjectName> — <Subtitle>

## Status
- **Phase:** <Phase>
- **Priority:** <Priority>
- **Blocked by:** <Blocked-by>

## Overview
<Overview>

## Current Progress
- ⏳ <Initial state — describe the starting point>

## Next Actions
- [ ] <First action item>

## Technical Decisions
| Decision | Choice | Rationale |
|---|---|---|
| | | |

## Links & Resources


## Notes
*Created: <YYYY-MM-DD>*
```

Get today's date: `date +%Y-%m-%d`

If the user provided technical decisions or links, populate those sections. Otherwise leave them as placeholders.

### Step 4 — Update Projects-Index.md

Read `"$VAULT/Projects/Projects-Index.md"` first to understand the current structure.

Add a new row to the correct priority section table using Edit (not Write):

| Priority | Section header |
|---|---|
| Critical | `## 🔴 Critical` |
| High | `## 🟠 High Priority` |
| Active | `## 🟡 Active` |
| Long-term or Blocked | `## 🔵 Long-term / Blocked` |
| Ongoing | `## 📋 Ongoing` |

Row format for Critical/High/Active/Long-term sections (3 columns):
```
| [[<ProjectName>/<ProjectName>]] | <Deadline or TBD> | <Phase> — <one-line status> |
```

Row format for Ongoing section (2 columns):
```
| [[<ProjectName>/<ProjectName>]] | <Brief description> |
```

Also update the `*Last updated: YYYY-MM-DD*` line at the bottom of the index.

### Step 5 — Confirm to user

Tell the user:
- Project note created at the full path
- Projects-Index.md updated with the wiki link
- Suggest `/obsidian-update` to keep the note current as work progresses

## Naming Conventions

- Format: `Title-Case-With-Hyphens` (e.g. `SE4-Networking`, `DB-Migration-Percona`)
- The directory name and the `.md` filename (without extension) must match exactly — required for Obsidian wiki links `[[Folder/File]]` to resolve
- No spaces, no underscores, no all-lowercase

## MCP Fallback (Google Drive)

If no local vault path is accessible:

1. Find the Projects folder: `mcp__claude_ai_Google_Drive__search_files`
2. Read Projects-Index.md: `mcp__claude_ai_Google_Drive__read_file_content`
3. Create the new project note: `mcp__claude_ai_Google_Drive__create_file` — **always specify `mimeType: text/plain`** so the file is stored as plain Markdown, not a Google Doc
4. Note: folder/directory structure cannot be created via MCP — warn the user that the project subdirectory won't exist and Obsidian sync may need to create it
5. Provide the updated Projects-Index.md row for the user to paste if the index cannot be updated via MCP
