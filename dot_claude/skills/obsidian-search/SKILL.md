---
name: obsidian-search
description: Search across the Obsidian vault for notes, projects, research, or daily entries. Use when the user says "search my notes", "find in Obsidian", "what did I write about X", "is there a note on X", "find the project about X", "search for tag X", "what projects mention X", "find my research on X", "show me all active projects", "what did I work on last week", or any question that requires looking up content in the vault rather than creating new content. Also use when the user asks "do I have a note on X?".
allowed-tools:
  - Read
  - Bash(find *)
  - Bash(grep *)
  - Bash(ls *)
  - Bash(test *)
  - Bash(uname *)
  - mcp__claude_ai_Google_Drive__search_files
  - mcp__claude_ai_Google_Drive__read_file_content
  - mcp__claude_ai_Google_Drive__download_file_content
---

# Obsidian Vault Search Skill

This skill is read-only — it never creates or modifies files.

## Vault Path Detection

```bash
test -d "/mnt/g/My Drive/notes" && echo "WSL"
```

- Prints "WSL" → `VAULT="/mnt/g/My Drive/notes"` (primary)
- Windows native (Claude Desktop, no `/mnt/g`) → `VAULT="G:\My Drive\notes"`
- Neither accessible → Google Drive MCP fallback (see below)

## Search Strategies

Choose the right strategy based on the query. Combine strategies for thorough results.

### Strategy A — Project name lookup

When the user references a project by name (exact or approximate):

```bash
ls "$VAULT/Projects/" | grep -i "<term>"
```

Read the matching project note in full. Summarize: current status, phase, recent progress, and next actions.

### Strategy B — Full-text keyword search

When the user asks "what did I write about X" or "find notes mentioning X":

```bash
# Find which files match
grep -r -i -l "<keyword>" "$VAULT/" --include="*.md"

# Show context around matches
grep -r -i -n -C 2 "<keyword>" "$VAULT/" --include="*.md"
```

List all matching files, then read the most relevant ones in full.

### Strategy C — Tag search

When the user asks to find notes with a specific tag:

```bash
grep -r -l "#<tag>" "$VAULT/" --include="*.md"
```

List results grouped by folder (Projects, Research, Daily).

### Strategy D — Date range search (Daily notes)

When the user asks "what did I work on last week" or "notes from May":

```bash
ls "$VAULT/Daily/" | grep "^<YYYY-MM>"
```

Read matching daily notes and summarize activity across the date range — don't return them verbatim.

### Strategy E — Project index overview

When the user asks "what projects do I have" or "show me all active projects":

Read `"$VAULT/Projects/Projects-Index.md"` and return its contents, organized by priority section.

### Strategy F — Folder-scoped search

When the user wants to restrict search to a specific area (Research, Daily, a specific project):

```bash
find "$VAULT/<folder>/" -name "*.md" | xargs grep -l -i "<keyword>" 2>/dev/null
```

## Presenting Results

Always present in this order:
1. **Best match** — the single most relevant file, with a 3-5 sentence summary
2. **Other matches** — remaining files with one-line descriptions of why they matched
3. **Search details** — which strategy was used

If no results found:
- Say explicitly: "No notes found matching '<term>' in the vault"
- Suggest related terms if the search was approximate
- Offer to create a new note via `/obsidian-research` or `/obsidian-project`

## Result Depth by Query Type

| Query type | Depth |
|---|---|
| Project name lookup | Read full note, summarize status + next actions |
| Keyword search | Show context snippets; offer to read a specific file fully |
| Tag search | List files, read the 2-3 most recently modified |
| Daily note range | Summarize across notes — do not return verbatim |
| Project index | Return full index content |

## MCP Fallback (Google Drive)

If no local vault path is accessible:

1. Use `mcp__claude_ai_Google_Drive__search_files` with relevant query terms
2. Note: Drive search is less precise than grep — warn the user results may be incomplete
3. Read matched files with `mcp__claude_ai_Google_Drive__read_file_content` or `download_file_content`
4. Present results as above
