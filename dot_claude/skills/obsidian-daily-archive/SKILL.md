---
name: obsidian-daily-archive
description: Archive daily notes older than the last two weeks into year/month subfolders, keeping only the most recent 14 days in the main Daily folder. Use when the user says "archive old daily notes", "clean up the daily folder", "move old dailies to archive", "archive dailies older than two weeks", or asks to tidy up Daily/. Can be run standalone, on a schedule (see the schedule skill), or via /loop.
allowed-tools:
  - Read
  - Bash(find *)
  - Bash(ls *)
  - Bash(mkdir *)
  - Bash(mv *)
  - Bash(test *)
  - Bash(date *)
  - Bash(uname *)
---

# Obsidian Daily Notes Archive Skill

This skill only moves files — it never edits daily note content.

## Vault Path Detection

Run these checks in order and use the first path that exists:

```bash
test -d "$HOME/Documents/notes" && echo "RCLONE"
test -d "/mnt/g/My Drive/notes" && echo "WSL"
```

1. `$HOME/Documents/notes` exists → `VAULT="$HOME/Documents/notes"` (rclone mount — primary)
2. `/mnt/g/My Drive/notes` exists → `VAULT="/mnt/g/My Drive/notes"` (WSL with G: mounted)
3. Windows native (Claude Desktop, no WSL paths) → `VAULT="G:\My Drive\notes"`
4. None of the above → this skill requires local filesystem access — see MCP note below

## Archive Layout

Daily notes older than 14 days move to:

```
$VAULT/Archive/Daily/<YYYY>/<MM>/<YYYY-MM-DD>.md
```

`<YYYY>/<MM>` come from the note's own date (the filename), not today's date.

## Task: Archive Old Daily Notes

### Step 1 — Compute the cutoff

Keep the most recent 14 calendar days (today plus the 13 days before it) in `Daily/`; archive anything older.

```bash
CUTOFF=$(date -d "-13 days" +%Y-%m-%d)
```

### Step 2 — Walk the Daily folder and move old notes

Filenames are `YYYY-MM-DD.md`, which sort lexicographically the same as chronologically, so plain string comparison works:

```bash
for f in "$VAULT/Daily"/*.md; do
  base=$(basename "$f" .md)
  [[ "$base" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue   # skip anything that isn't a dated note
  if [[ "$base" < "$CUTOFF" ]]; then
    yyyy="${base:0:4}"
    mm="${base:5:2}"
    mkdir -p "$VAULT/Archive/Daily/$yyyy/$mm"
    mv "$f" "$VAULT/Archive/Daily/$yyyy/$mm/"
  fi
done
```

Run this for real (not a dry run) once the vault path is confirmed — but list which files will move before running it, so the user sees what's about to happen.

### Step 3 — Note on nav links (no action needed)

Daily notes link to the previous/next day with plain `[[Daily/<date>]]`-style links. Once a note is archived, that literal path no longer exists, but Obsidian's wikilink resolution falls back to a vault-wide filename match — since every daily note's filename (`YYYY-MM-DD`) is unique, these links keep resolving to the archived note automatically. Do not rewrite nav links as part of this skill.

### Step 4 — Report to the user

Summarize:
- How many notes were archived, and the date range covered
- How many dated notes remain in `Daily/` (should be ≤14)
- If nothing was old enough to archive, say so explicitly rather than running mkdir/mv for nothing

### Recurring use

If the user wants this to run automatically instead of on-demand, point them at the `/loop` or `schedule` skills to run this skill on a recurring cadence (e.g. weekly) rather than re-invoking it manually each time.

## MCP Fallback (Google Drive)

Not supported. The available Drive MCP tools cover create/read/search/download but have no move or delete operation, so files can't be relocated into `Archive/Daily/...` this way. If no local vault path is accessible, tell the user this skill needs to wait until they have local (rclone/WSL) access, or that they can move the old notes manually in the Drive UI.
