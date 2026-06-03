---
name: obsidian-update
description: Update an existing project note in the Obsidian vault. Use when the user says "update the project note", "mark this as done", "add a next action", "update progress on X", "this is now blocked by X", "we decided to use X", "log a technical decision", "add a link to the project", "change the status", or names a specific project followed by a status change or update. Also trigger when the user says "update Staq", "update DB migration", or any project name alongside information that should be recorded.
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
  - mcp__claude_ai_Google_Drive__download_file_content
  - mcp__claude_ai_Google_Drive__create_file
---

# Obsidian Project Update Skill

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
| "note: ..." / "add note" / "FYI ..." | `Notes/` subfolder | Create new note file; add wiki link to `## Notes` in main file |
| "research: ..." / "save research on X" | `Research/` subfolder | Create new research file; add wiki link to `## Research` in main file |

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

**Notes — create a file, not inline content:**

Notes and research are stored as separate files in subfolders, not appended inline to the main file. The main file's `## Notes` and `## Research` sections are link indexes only.

*Adding a note:*
1. Derive a short slug from the content: lowercase, hyphens, e.g. `equinix-bgp-config`
2. Create the directory if needed: `mkdir -p "$VAULT/Projects/<ProjectName>/Notes"`
3. Write `"$VAULT/Projects/<ProjectName>/Notes/<YYYY-MM-DD>-<slug>.md"`:
   ```markdown
   # <Title>

   *Project: [[../<ProjectName>]]*
   *Date: <YYYY-MM-DD>*

   <Content>

   *Last edited: <YYYY-MM-DD>*
   ```
4. Add a wiki link to the main file's `## Notes` section using Edit:
   `- [[Notes/<YYYY-MM-DD>-<slug>|<Title>]] — <YYYY-MM-DD>`
   If the `## Notes` section doesn't exist, append it before the `*Created:*` line.

*Adding research:*
1. Derive a slug from the topic
2. Create the directory if needed: `mkdir -p "$VAULT/Projects/<ProjectName>/Research"`
3. Write `"$VAULT/Projects/<ProjectName>/Research/<slug>.md"`:
   ```markdown
   # <Title>

   *Project: [[../<ProjectName>]]*
   *Date: <YYYY-MM-DD>*

   <Content>

   *Last edited: <YYYY-MM-DD>*
   ```
4. Add a wiki link to the main file's `## Research` section using Edit:
   `- [[Research/<slug>|<Title>]] — <YYYY-MM-DD>`
   If the `## Research` section doesn't exist, append it before `## Notes`.

### Step 4 — Update Projects-Index.md if priority changed

If the user's update changes the Priority or moves the project to/from Blocked status:
- Read `"$VAULT/Projects/Projects-Index.md"`
- Move the project's row to the correct priority section table
- Update the status text in the row
- Update the `*Last updated:*` line at the bottom

Only touch the index for priority/blocking changes — not for routine progress updates.

### Step 5 — Update the Last edited line

After all section edits, update or append the `*Last edited:*` line at the very bottom of the file:

- If the file already contains a `*Last edited:*` line, replace it: `*Last edited: <YYYY-MM-DD>*`
- If no such line exists, append it on a new line at the end of the file

This line is used by `daily-briefing` for staleness detection (more reliable than filesystem timestamps on Google Drive mounts).

### Step 6 — Confirm to user

Tell the user which project was updated, which sections changed, and show the updated content.

## Batching Multiple Updates

If the user provides a large update ("here's what happened this week: ..."), process all changes in a single Edit pass per section. Group all changes to the same section together rather than making many small sequential edits.

## MCP Fallback (Google Drive)

If no local vault path is accessible:

**Always use these parameters when calling `create_file`:**
- `contentMimeType: "text/plain"`
- `disableConversionToGoogleType: true`
- `parentId: <folder-id>`

Both flags are required. Without `disableConversionToGoogleType`, Drive silently converts `text/plain` to a Google Doc.

**Step-by-step:**

1. Find the project file: search `title = '<ProjectName>.md' and '<projects-folder-id>' in parents`
2. Read it: `mcp__claude_ai_Google_Drive__read_file_content` or `download_file_content`
3. Apply all changes in memory to build the full updated file content
4. Create the replacement file with the same name, `contentMimeType: text/plain`, `disableConversionToGoogleType: true`, `parentId`
5. Tell the user: "Old file ID: `<id>` — trash it in Google Drive to remove the duplicate"

Note: MCP cannot do surgical edits — the full file is replaced. This is why local path (WSL or Windows) is always preferred for updates.
