---
name: obsidian-project-archive
description: Archive a completed project in the Obsidian vault — moves it into a dated Archive/Projects/<year>/<month> folder and updates the Projects Index. Use when the user says "archive this project", "this project is done, archive it", "move X to the archive", "archive completed projects", or names a project alongside "done"/"complete"/"finished"/"wrapped up" indicating it should be moved out of active tracking. Do NOT use this just to mark a project's phase as Completed without moving it — for status-only changes use obsidian-update.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(find *)
  - Bash(grep *)
  - Bash(ls *)
  - Bash(mkdir *)
  - Bash(mv *)
  - Bash(test *)
  - Bash(date *)
  - Bash(uname *)
  - mcp__claude_ai_Google_Drive__search_files
  - mcp__claude_ai_Google_Drive__read_file_content
  - mcp__claude_ai_Google_Drive__create_file
---

# Obsidian Project Archive Skill

## Vault Path Detection

Run these checks in order and use the first path that exists:

```bash
test -d "$HOME/Documents/notes" && echo "RCLONE"
test -d "/mnt/g/My Drive/notes" && echo "WSL"
```

1. `$HOME/Documents/notes` exists → `VAULT="$HOME/Documents/notes"` (rclone mount — primary)
2. `/mnt/g/My Drive/notes` exists → `VAULT="/mnt/g/My Drive/notes"` (WSL with G: mounted)
3. Windows native (Claude Desktop, no WSL paths) → `VAULT="G:\My Drive\notes"`
4. None of the above → Google Drive MCP fallback is limited — see below; a directory move generally requires local access

## Archive Layout

Completed projects move to:

```
$VAULT/Archive/Projects/<YYYY>/<MM>/<ProjectName>/
```

`<YYYY>/<MM>` is the completion year/month (default: today's date), not the project's creation date. The whole project directory (including its `Notes/` and `Research/` subfolders) moves as a unit — nothing is left behind in `Projects/`.

## Task: Archive a Completed Project

### Step 1 — Identify the project

```bash
ls "$VAULT/Projects/" | grep -i "<name>"
```

If ambiguous or not found, list close matches and ask the user to confirm. If the user gives an exact name that doesn't match, also check whether it's already archived before giving up:

```bash
find "$VAULT/Archive/Projects" -maxdepth 3 -type d -iname "*<name>*"
```

If it's already archived, tell the user where it lives and stop — do not move it again.

### Step 2 — Confirm completion details

- **Completion date** — default to today (`date +%Y-%m-%d`); use a different date only if the user specifies one (e.g. "we actually finished this last month")
- **Completion note** — one line for the Projects Index (e.g. "MCP docs server PoC shipped"). Ask if not provided, or infer briefly from conversation context.

### Step 3 — Update the project note before moving

Read `"$VAULT/Projects/<ProjectName>/<ProjectName>.md"` in full, then use Edit (not Write):

- In `## Status`, change the `**Phase:**` line to `**Phase:** Completed`
- Replace or append the `*Last edited:*` line at the bottom with the completion date

### Step 4 — Move the project directory

```bash
YYYY=$(date +%Y)   # or derived from the completion date if the user gave one
MM=$(date +%m)
mkdir -p "$VAULT/Archive/Projects/$YYYY/$MM"
mv "$VAULT/Projects/<ProjectName>" "$VAULT/Archive/Projects/$YYYY/$MM/<ProjectName>"
```

### Step 5 — Update Projects-Index.md

Read `"$VAULT/Projects/Projects-Index.md"` first.

1. Remove the project's row from whatever priority section it currently sits in (Critical / High / Active / Long-term-Blocked / Ongoing).
2. Add a row to `## ✅ Completed` (create this section, right before `## 📋 Ongoing`, if it doesn't exist yet):
   ```
   | [[Archive/Projects/<YYYY>/<MM>/<ProjectName>/<ProjectName>]] | <completion-date> | <completion-note> |
   ```
3. Update the `*Last updated: YYYY-MM-DD*` line at the bottom.

Use Edit for all of this — never rewrite the whole index with Write.

### Step 6 — Flag dangling references

```bash
grep -rl "<ProjectName>" "$VAULT" --include="*.md"
```

Exclude the archived note itself and the index (already updated). List any remaining files that reference the project. Obsidian's wikilink resolution falls back to a vault-wide filename match when the literal path in a `[[...]]` link no longer exists, so links like `[[<ProjectName>/<ProjectName>]]` elsewhere will typically keep resolving correctly on their own — no edits needed. Mention this to the user rather than silently rewriting those files; only fix them if the user asks.

### Step 7 — Confirm to user

Report:
- Old path and new archive path
- Projects-Index.md updated (row moved to Completed)
- Any other files found referencing the project (informational, per Step 6)

## MCP Fallback (Google Drive)

Moving/deleting a folder isn't supported by the available Drive MCP tools (no move or delete operation, only create/read/search/download). If no local vault path is accessible:

1. Tell the user a full directory move can't be done via MCP — they'll need to move it manually in the Drive UI or Obsidian once they have local/mounted access.
2. You can still update `Projects-Index.md` for them: search `title = 'Projects-Index.md'`, read it, build the updated content (row moved to `## ✅ Completed`, pointing at the *intended* archive path), and create a replacement file with `contentMimeType: text/plain`, `disableConversionToGoogleType: true`, `parentId`.
3. Tell the user: "Old Projects-Index.md ID: `<id>` — trash it in Google Drive to remove the duplicate" and remind them the wikilink target assumes they'll actually move the folder to that path.
