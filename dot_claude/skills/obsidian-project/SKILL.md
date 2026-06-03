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

Run these checks in order and use the first path that exists:

```bash
test -d "$HOME/Documents/notes" && echo "RCLONE"
test -d "/mnt/g/My Drive/notes" && echo "WSL"
```

1. `$HOME/Documents/notes` exists → `VAULT="$HOME/Documents/notes"` (rclone mount — primary)
2. `/mnt/g/My Drive/notes` exists → `VAULT="/mnt/g/My Drive/notes"` (WSL with G: mounted)
3. Windows native (Claude Desktop, no WSL paths) → `VAULT="G:\My Drive\notes"`
4. None of the above → Google Drive MCP fallback (see below)

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
mkdir -p "$VAULT/Projects/<ProjectName>/Notes"
mkdir -p "$VAULT/Projects/<ProjectName>/Research"
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


## Research
<!-- Research files live in Research/ — links added here automatically -->

## Notes
<!-- Note files live in Notes/ — links added here automatically -->

*Created: <YYYY-MM-DD>*
*Last edited: <YYYY-MM-DD>*
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

**Always use these parameters when calling `create_file`:**
- `contentMimeType: "text/plain"`
- `disableConversionToGoogleType: true`
- `parentId: <folder-id>`

Both flags are required. Without `disableConversionToGoogleType`, Drive silently converts `text/plain` to a Google Doc.

**Step-by-step:**

1. Find the Projects folder ID: search `title = 'Projects' and mimeType = 'application/vnd.google-apps.folder'`
2. Create the project note with the template content, `contentMimeType: text/plain`, `disableConversionToGoogleType: true`, `parentId`
3. Note: subfolder (project directory) cannot be created via MCP — warn the user; Obsidian sync will create it when the vault next syncs
4. For Projects-Index.md: search `title = 'Projects-Index.md' and '<projects-folder-id>' in parents`, read it, build the updated content with the new row, then create a replacement file
   - Tell the user: "Old Projects-Index.md ID: `<id>` — trash it in Google Drive to remove the duplicate"
5. Provide the new Projects-Index.md row to the user in case they prefer to paste it manually
