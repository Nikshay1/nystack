# Lead judgment

## Filter

- **Filled-up reviews.** A reviewer with no real issues inflates nits. All nits usually means the code is fine. Say so.
- **Hypothetical versus reachable.** A finding about an input counts only if a real caller can produce that input. Trace the call site.
- **Premature abstraction.** "Extract an interface" is not a finding unless the code needs to change in a second way.
- **"I would do it differently."** Not a finding without a concrete problem. Dismiss with the reason.
- **Missing context.** Suggestions that conflict with repository conventions or constraints the reviewer could not see. Dismiss politely.

## Keep

- Findings two models raised independently.
- Findings that show a concrete execution path.
- Findings that reveal a gap in your own understanding.
- Correctness and security findings, even from one model, until you have checked them.

Check every finding you act on against the code yourself before it goes in the report.
