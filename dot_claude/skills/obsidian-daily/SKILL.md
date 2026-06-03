---
name: obsidian-daily
description: Create or append to the daily note in the Obsidian vault. Use when the user says "daily note", "today's note", "log this to today", "add to my daily", "EOD note", "end of day note", "start of day", "what did I work on today", or asks to log tasks, accomplishments, blockers, or meeting notes for today. Also trigger when the user says "log this" or "note this for today" without specifying a project or research context.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(find *)
  - Bash(ls *)
  - Bash(mkdir *)
  - Bash(test *)
  - Bash(date *)
  - Bash(uname *)
  - mcp__claude_ai_Google_Drive__search_files
  - mcp__claude_ai_Google_Drive__read_file_content
  - mcp__claude_ai_Google_Drive__create_file
---

# Obsidian Daily Notes Skill

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

## Get Today's Date

```bash
date +%Y-%m-%d        # filename date: 2026-06-02
date +%A              # day of week: Monday
date -d "yesterday" +%Y-%m-%d   # prev nav link
date -d "tomorrow" +%Y-%m-%d    # next nav link
```

Daily file path: `"$VAULT/Daily/YYYY-MM-DD.md"`

Create the directory if needed: `mkdir -p "$VAULT/Daily"`

## Task: Create or Append to Today's Note

### If the file does NOT exist — Create it

```markdown
# Daily — <YYYY-MM-DD> (<Day-of-week>)

## Focus
- 

## Log


## Accomplished
- 

## Blockers / Notes
- 

---
*[[Daily/<prev-date>]] | [[Daily/<next-date>]]*
```

- The prev/next nav links may point to files that don't yet exist — that is fine in Obsidian
- If the user provided content at creation time, populate the relevant section immediately rather than leaving it blank

### If the file ALREADY exists — Append to it

Read the file first. Then determine which section gets the new content and use Edit to append surgically — do NOT rewrite the file.

| User says | Target section |
|---|---|
| "log this" / general note | `## Log` |
| "I finished X" / "just completed X" | `## Accomplished` |
| "blocked on X" / "waiting on X" | `## Blockers / Notes` |
| "meeting notes: ..." | New `## Meeting: <Topic>` section before the nav footer |
| "my focus today is X" | `## Focus` bullet |
| "EOD" / "end of day" | Synthesize full update — see EOD mode below |

For Log entries: prepend a time marker if the user mentions a time (`14:30 —`), otherwise no timestamp.

### EOD (End of Day) Summarization

When the user says "EOD", "end of day note", or "wrap up today":

1. Review the current conversation for:
   - Tasks completed or in progress
   - Decisions made
   - Blockers encountered
   - Projects touched
2. Write a full update with all sections populated
3. Add wiki links to any project notes discussed today under a `## Project Links` section

## After Writing

Tell the user:
- The date and full path written to
- Which section was updated, or that a new note was created
- If new file: offer to set the Focus for today

## MCP Fallback (Google Drive)

If no local vault path is accessible:

**Always use these parameters when calling `create_file`:**
- `contentMimeType: "text/plain"`
- `disableConversionToGoogleType: true`
- `parentId: <folder-id>`

Both flags are required. Without `disableConversionToGoogleType`, Drive silently converts `text/plain` to a Google Doc.

**Step-by-step:**

1. Find the Daily folder ID: search `title = 'Daily' and mimeType = 'application/vnd.google-apps.folder'`
   - If not found, create it: `create_file` with `mimeType: application/vnd.google-apps.folder`, `parentId` = notes root folder ID
2. Search for today's existing note: `title = 'YYYY-MM-DD.md' and '<daily-folder-id>' in parents`
3. If the file exists:
   - Read it with `mcp__claude_ai_Google_Drive__read_file_content`
   - Build full updated content (append new section)
   - Create a new file with the same name, correct MIME type flags
   - Tell the user: "Old file ID: `<id>` — trash it in Google Drive to remove the duplicate"
4. If the file does not exist: create it with the template content
5. Tell the user the MCP path was used
