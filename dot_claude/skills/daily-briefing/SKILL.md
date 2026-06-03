---
name: daily-briefing
description: Generate a daily briefing summarizing calendar events, Jira tickets, project statuses, stale projects, and General SRE reminders. Use when the user says "daily briefing", "brief me on today", "what's on my plate", "morning briefing", "what do I have today", "what's happening tomorrow", "day summary for [date]", "standup prep", or "what should I focus on today". Accepts a date argument — defaults to today if none given.
allowed-tools:
  - Read
  - Bash(date *)
  - Bash(find *)
  - Bash(grep *)
  - Bash(ls *)
  - Bash(test *)
  - Bash(stat *)
  - Bash(uname *)
  - mcp__claude_ai_Google_Calendar__list_events
  - mcp__claude_ai_Google_Calendar__list_calendars
  - mcp__claude_ai_Atlassian__getAccessibleAtlassianResources
  - mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql
  - mcp__claude_ai_Atlassian__getJiraIssue
---

# Daily Briefing Skill

Generates a structured daily briefing by aggregating the vault, calendar, and Jira. This skill is read-only — it never creates or modifies files.

## Step 0 — Resolve the target date

Parse the user's intent:

| User says | Target date |
|---|---|
| "today" / no date given | Current date |
| "tomorrow" | Current date + 1 day |
| "yesterday" | Current date - 1 day |
| Day name ("Monday") | Next occurrence of that day |
| Specific date ("June 5") | That date |

Compute the resolved date using `date`:
```bash
date +%Y-%m-%d                        # today
date -d "tomorrow" +%Y-%m-%d          # tomorrow
date -d "yesterday" +%Y-%m-%d         # yesterday
date -d "next Monday" +%Y-%m-%d       # named day
```

Also compute the full human-readable form: `date -d "<date>" "+%A, %B %-d, %Y"` (e.g., "Monday, June 2, 2026").

Set `TARGET_DATE` to the resolved `YYYY-MM-DD` string. All subsequent steps use this date.

## Step 1 — Vault Path Detection

```bash
test -d "$HOME/Documents/notes" && echo "RCLONE"
test -d "/mnt/g/My Drive/notes" && echo "WSL"
```

1. `$HOME/Documents/notes` → `VAULT="$HOME/Documents/notes"` (rclone — primary)
2. `/mnt/g/My Drive/notes` → `VAULT="/mnt/g/My Drive/notes"` (WSL)
3. Windows native → `VAULT="G:\My Drive\notes"`
4. None → skip vault sections and note that the vault is unavailable

## Step 2 — Calendar (run in parallel with Step 3 and Step 4)

Fetch events for the target date using the full day window in the local timezone:

```
startTime: <TARGET_DATE>T00:00:00
endTime:   <TARGET_DATE>T23:59:59
orderBy:   startTime
pageSize:  50
```

Format each event as:
- `HH:MM–HH:MM  Event Title  [Location/Meet link if present]`
- All-day events listed first with `All day` prefix
- Declined events: omit
- Tentative events: mark with `(tentative)`

If no events: "No calendar events."

## Step 3 — Jira: QIT + QITSD (run in parallel with Step 2 and Step 4)

First, get the Atlassian cloud ID: call `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` and use the returned `id` field.

Run two JQL queries using `mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql`:

**Query A — My open tickets:**
```
project in (QIT, QITSD) AND assignee = currentUser() AND status not in (Done, Closed, Resolved) ORDER BY priority DESC, updated DESC
```

**Query B — Recently updated unassigned/team tickets:**
```
project in (QIT, QITSD) AND status in ("In Progress", "To Do") AND updated >= -1d ORDER BY updated DESC
```

Request fields: `["summary", "status", "priority", "issuetype", "assignee", "updated"]`
Set `maxResults: 25` for each query, `responseContentFormat: "markdown"`.

Format output grouped by priority:
```
🔴 [QIT-123] Critical ticket title (In Progress)
🟠 [QIT-456] High priority ticket (To Do)
🟡 [QITSD-78] Medium ticket (In Progress)
```

Use emoji for priority: 🔴 Highest/Critical, 🟠 High, 🟡 Medium, 🔵 Low.
If Query A returns nothing: "No open Jira tickets assigned to you."
Include Query B results as a separate "Recently updated" subsection, deduped against Query A.

## Step 4 — Vault: Projects and Staleness (run in parallel with Step 2 and Step 3)

### 4a — Read Projects-Index.md

Read `"$VAULT/Projects/Projects-Index.md"` to get the full project list and their priority tiers.

### 4b — Read top-priority project notes

For Critical and High Priority projects, read their full notes and extract:
- Current Phase and Blocked-by from `## Status`
- Last 2-3 items from `## Current Progress`
- First 2 unchecked items from `## Next Actions`

### 4c — Detect stale projects

For every project in the index (Critical, High, Active tiers), check the last-modified time of its note file:

```bash
stat -c "%Y" "$VAULT/Projects/<Name>/<Name>.md"
```

Compare against `TARGET_DATE`. A project is **stale** if:
- Its priority is Critical or High AND the note hasn't been modified in **> 7 days**
- Its priority is Active AND the note hasn't been modified in **> 14 days**

List stale projects with: project name, priority, and how many days since last update.

### 4d — Read General SRE reminders

Read `"$VAULT/Projects/General-SRE/General-SRE.md"`.

Extract the Recurring Tasks table and surface tasks that are due based on their frequency:
- **Daily** tasks → always show
- **Weekly** tasks → show if TARGET_DATE is a Monday (or first workday of the week)
- **~Weekly** tasks → show if it's been > 5 days since the last daily note mentioning that task

Also check if TARGET_DATE is a Monday and flag the weekly team sync if so.

### 4e — Read the daily note for TARGET_DATE (if it exists)

Check for `"$VAULT/Daily/<TARGET_DATE>.md"`. If it exists:
- Extract the `## Focus` section (what was planned)
- Extract the `## Accomplished` section (for past dates)
- Extract any open `- [ ]` items from `## Log` or other sections

For **future dates**: show the Focus if set (the user may have pre-planned).
For **past dates**: show Accomplished and any open items.
For **today**: show Focus if set, flag open items as still pending.

## Step 5 — Assemble the Briefing

Output the briefing in this format:

---

```
# Daily Briefing — <Weekday, Month D, YYYY>

## 📅 Calendar
<events or "No calendar events.">

## 🎫 Jira — QIT + QITSD
### Assigned to me
<tickets>
### Recently updated
<other tickets, deduped>

## 🔴 Critical
### <ProjectName>
Phase: ... | Blocked by: ...
Progress: ...
Next: ...

## 🟠 High Priority
### <ProjectName>
Phase: ... | Blocked by: ...
Progress: ...
Next: ...

## 🟡 Active Projects
| Project | Phase | Next action |
|---|---|---|
| <Name> | <Phase> | <First open next action> |
...

## ⚠️ Stale Projects
> These projects haven't been updated recently and may need attention:
- **<Name>** (Critical) — last updated X days ago
- **<Name>** (Active) — last updated X days ago

## 📋 General SRE — Today's Reminders
**Daily:**
- Ticket triage — QIT, QITSD
- System health checks

**This week:** (if Monday)
- Patch/update review
- Team sync with Honore, Cliff, Brandon

**Sundonna check-in** — due if > 5 days since last mention

## 📓 Daily Note
Focus: <from daily note, or "Not set — use /obsidian-daily to set your focus">
Open items: <unchecked tasks if any>
```

---

## Parallelism

Run Steps 2, 3, and 4 concurrently — calendar, Jira, and vault reads are independent. Assemble Step 5 only after all three complete.

## Handling missing data

- Vault unavailable: skip all vault sections, note at top: "⚠️ Vault not accessible — showing calendar and Jira only"
- Calendar unavailable: skip calendar section
- Jira unavailable or unauthenticated: skip Jira section, note: "⚠️ Jira unavailable"
- Project note missing for an indexed project: flag it in Stale Projects as "note file not found"

## Date edge cases

- Weekend dates: note at the top "(Weekend)" — still show calendar events and vault status; skip Jira triage reminder
- Future dates > 7 days out: show calendar events only; vault/Jira sections show current state with a note that they reflect today's data, not the future date
