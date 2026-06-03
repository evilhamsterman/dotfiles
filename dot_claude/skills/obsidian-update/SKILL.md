---
name: obsidian-update
description: Update an existing project note in the Obsidian vault. Use when the user says "update the project note", "mark this as done", "add a next action", "update progress on X", "this is now blocked by X", "we decided to use X", "log a technical decision", "add a link to the project", "change the status", or names a specific project followed by a status change or update. Also trigger when the user says "update Staq", "update DB migration", or any project name alongside information that should be recorded.
allowed-tools:
  - Read
  - Edit
  - Bash(find *)
  - Bash(grep *)
  - Bash(ls *)
  - Bash(test *)
  - Bash(date *)
  - Bash(uname *)
  - mcp__claude_ai_Google_Drive__search_files
  - mcp__claude_ai_Google_Drive__read_file_content
  - mcp__claude_ai_Google_Drive__download_file_content
---

# Obsidian Project Update Skill

## Vault Path Detection

```bash
test -d "/mnt/g/My Drive/notes" && echo "WSL"
```

- Prints "WSL" → `VAULT="/mnt/g/My Drive/notes"` (primary)
- Windows native (Claude Desktop, no `/mnt/g`) → `VAULT="G:\My Drive\notes"`
- Neither accessible → Google Drive MCP fallback (see below)

## Task: Update a Project Note

### Step 1 — Find the project

If the user names a project explicitly, look for: `"$VAULT/Projects/<ProjectName>/<ProjectName>.md"`

If the name is ambiguous or approximate:
```bash
ls "$VAULT/Projects/"
find "$VAULT/Projects" -name "*.md" | grep -i "<partial-name>"
```

List options and ask the user to confirm if multiple matches.

Always read the full current content of the project file before making any edits.

### Step 2 — Map the request to sections

| User request | Section | Action |
|---|---|---|
| "phase is now X" / "we're in X phase" | `## Status` | Replace the Phase line |
| "priority changed to X" | `## Status` | Replace the Priority line |
| "blocked by X" / "no longer blocked" | `## Status` | Replace the Blocked by line |
| "update overview" | `## Overview` | Replace the overview paragraph |
| "done with X" / "completed X" / "✅ X" | `## Current Progress` | Change `⏳` or `🔄` → `✅` on matching item |
| "working on X" / "started X" | `## Current Progress` | Change `⏳` → `🔄`, or add `- 🔄 X` |
| "add new milestone / task to progress" | `## Current Progress` | Append `- ⏳ <item>` |
| "add to-do" / "next action" / "need to do X" | `## Next Actions` | Append `- [ ] X` |
| "done with task X" / "check off X" | `## Next Actions` | Change `- [ ] X` → `- [x] X` |
| "decided to use X because Y" | `## Technical Decisions` | Add table row |
| "add link" / "resource is X" | `## Links & Resources` | Append line |
| "note: ..." / "add note" / "FYI ..." | `## Notes` | Append `*YYYY-MM-DD:* <content>` |

Get today's date for notes: `date +%Y-%m-%d`

### Step 3 — Edit surgically

Use **Edit** (never Write) for all modifications. Make the smallest correct change.

**Status section:** Find the exact current line and replace only that line.

**Current Progress:** 
- Completing: replace `⏳ <text>` or `🔄 <text>` with `✅ <text>` on the matching line
- Starting: replace `⏳ <text>` with `🔄 <text>`
- Adding: append `- ⏳ <new item>` to the list

**Next Actions:**
- Completing: change `- [ ] <text>` → `- [x] <text>` — do NOT delete completed tasks; `[x]` items show history
- Adding: append `- [ ] <text>`

**Technical Decisions table:** Add new rows only. Never modify existing rows unless correcting an error.

**Links & Resources:** Append new links as `- <Description>: <URL>` or `- <URL>`

**Notes:** Append `*<YYYY-MM-DD>:* <content>` — never edit existing notes entries

### Step 4 — Update Projects-Index.md if priority changed

If the user's update changes the Priority or moves the project to/from Blocked status:
- Read `"$VAULT/Projects/Projects-Index.md"`
- Move the project's row to the correct priority section table
- Update the status text in the row
- Update the `*Last updated:*` line at the bottom

Only touch the index for priority/blocking changes — not for routine progress updates.

### Step 5 — Confirm to user

Tell the user which project was updated, which sections changed, and show the updated content.

## Batching Multiple Updates

If the user provides a large update ("here's what happened this week: ..."), process all changes in a single Edit pass per section. Group all changes to the same section together rather than making many small sequential edits.

## MCP Fallback (Google Drive)

If no local vault path is accessible:

1. Find the project file: `mcp__claude_ai_Google_Drive__search_files`
2. Read it: `mcp__claude_ai_Google_Drive__read_file_content` or `download_file_content`
3. Since MCP doesn't support surgical edits, build the complete updated file content in memory and recreate the file using `mcp__claude_ai_Google_Drive__create_file` with **`mimeType: text/plain`**
4. Warn the user that the MCP path replaces the full file content
