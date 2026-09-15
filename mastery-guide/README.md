# Mastery Guide — From Copy-Paste to Junior Cloud Engineer

You are at S14 done (~20-25% if copy-paste, ~40-45% if you can rebuild blind).
Target after this folder: S18 + P3→P2→P4→P1 + SAA pass = ~65% junior.

Rule: no new tool until you can rebuild the last one without the guide.

## The mastery loop (use for every session/project)

1. **Follow once** — paste one command at a time, note expected output.
2. **Explain once** — cover the guide, say out loud what each flag does.
   Example: `aws sqs delete-message --queue-url X --receipt-handle Y` =
   delete needs handle, not body; receive only hides.
3. **Break once** — intentionally cause the classic error, then fix it:
   `BucketNotEmpty` (delete file first), `Topic does not exist` (list-topics first),
   `port allocated` (docker rm -f owner), `past [200~` (paste one line).
4. **Rebuild blind** — delete resources, close guide, rebuild from memory.
   Pass = works + you can answer "why?" for every line.

If step 4 fails, you are still copy-paste. Repeat, don't advance.

## How to use this folder

* `weeks.md` — 12-week plan at ~1hr/day. What to master each week, done-definition.
* `drills.md` — 5-minute self-tests per area. Fail a drill = redo that week.
* Track: check `github.com/settings/billing` weekly (quota), `git log --oneline` for proof of builds.

## Environment (every terminal)

```bash
floci start --persist .floci-data
eval $(floci env)
aws sts get-caller-identity  # expect 000000000000
```
