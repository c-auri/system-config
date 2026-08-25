# Code Conventions

Prioritize portability and simplicity over raw performance, scripts should generally run without a build step. Rewrite for performance when it becomes a bottleneck, not before. The primary target are recent Ubuntu systems, compatibility with other Unix-like systems is nice to have but not a must.

## Naming

### Scripts

- Use kebab-case (e.g., `sync-db-snapshots`, `validate-schema`)
- Keep it short but readable
- Names should hint at purpose

### Variables

- Put the unit in the name: `IDLE_DIM_AFTER_SECONDS`, not `IDLE_DIM_AFTER`
  - Matters most for config a user sets, where the name is the whole interface
  - Place the unit where the name reads naturally, not always at the end

## Shell Scripts

### Language Choice

- Default options: sh, bash, awk, Python
- Other languages need good reason + approval in the planning process

### Structure and Formatting

- Shebang, blank line, then first code
- Brief comment at top explaining what the script does
- Allman-style control flow statements: `then`, `do`, etc. on new line, no `;` before the break
- Allman-style function bodies: opening brace on its own line
  - Declare with `function name` in bash, and with `name()` in sh-compatible files, since `function` is not POSIX
  - Trivial definitions may stay on one line, braces included: `cdr() { cd $(git root); }`

**Correct:**
```bash
#!/bin/bash

# Syncs database snapshots from production to dev

function sync_snapshot
{
    echo "Syncing"
}

if [[ $? -eq 0 ]]
then
    sync_snapshot
fi
```

**Incorrect:**
```bash
#!/bin/bash
function sync_snapshot {
    echo "Syncing"
}
if [[ $? -eq 0 ]]; then
    sync_snapshot
fi
```

### Error Handling

- Fail fast; don't continue after a fatal error
- No exit code specification yet; add as needed

## Documentation

### READMEs
- Individual components should have a README close to the relevant code
- Short and focused
- Include: 
  - what it's for
  - what it does
  - dependencies
  - design decisions
  - verification steps
- Skip: 
  - UI walkthroughs
  - visual minutiae
  - file or feature tables when prose covers them
- Leave no open decisions; document what you've decided
- Explanations for implementation details go in code comments, not the README

### Comments
- Explain the *why* behind important decisions
- Explain non-obvious *what*: if terse shell syntax isn't immediately clear to someone unfamiliar with it, explain it
  - For complex regexes: include explanation and examples
  - For abbreviation-heavy arguments: clarify what they do
