# Style Guide Review

**Generated:** 2026-03-06T00:00:00Z
**Scope:** branch: main vs origin/main
**Rules loaded:** 8

## Summary

| Severity   | Count |
|------------|-------|
| Violation  | 2     |
| Warning    | 3     |
| Suggestion | 0     |
| **Total**  | 5     |

---

## Violations

### V1: set -euo pipefail must come before source

- **Severity:** Violation
- **Rule:** New `.mise-tasks/` scripts must follow the header pattern: `set -euo pipefail` before `source "$(dirname "$0")/utils"`
- **File:** `.mise-tasks/scaffold` (line 24–25)
- **Context tags:** shell, bash, mise-tasks

**Found:**
```bash
source "$(dirname "$0")/utils"
set -euo pipefail
```

**Expected:**
```bash
set -euo pipefail

source "$(dirname "$0")/utils"
```

**Fix:** In `.mise-tasks/scaffold`, move `set -euo pipefail` (line 25) to before `source "$(dirname "$0")/utils"` (line 24).

---

### V2: set -euo pipefail must come before source

- **Severity:** Violation
- **Rule:** New `.mise-tasks/` scripts must follow the header pattern: `set -euo pipefail` before `source "$(dirname "$0")/utils"`
- **File:** `.mise-tasks/upversion` (line 45–46)
- **Context tags:** shell, bash, mise-tasks

**Found:**
```bash
source "$(dirname "$0")/utils"
set -euo pipefail
```

**Expected:**
```bash
set -euo pipefail

source "$(dirname "$0")/utils"
```

**Fix:** In `.mise-tasks/upversion`, move `set -euo pipefail` (line 46) to before `source "$(dirname "$0")/utils"` (line 45).

---

## Warnings

### W1: Stale path in DOCUMENTATION heredoc

- **Severity:** Warning
- **Rule:** Always verify task names against `mise.toml` before documenting them
- **File:** `.mise-tasks/scaffold` (lines 10–13)
- **Context tags:** docs, bash

**Found:**
```
bash scripts/scaffold.sh --src /path/to/template --dest /path/to/project
bash scripts/scaffold.sh --src /path/to/template --dest /path/to/project --non-interactive
bash scripts/scaffold.sh --src /path/to/template --dest /path/to/project --project myapp
bash scripts/scaffold.sh  # Uses current directory for both src and dest
```

**Expected:**
```
mise run scaffold -- --src /path/to/template --dest /path/to/project
bash .mise-tasks/scaffold --src /path/to/template --dest /path/to/project
```

**Fix:** In `.mise-tasks/scaffold`, update the DOCUMENTATION heredoc Usage section to reference `mise run scaffold` or `bash .mise-tasks/scaffold` instead of `bash scripts/scaffold.sh`.

---

### W2: Stale path in DOCUMENTATION heredoc

- **Severity:** Warning
- **Rule:** Always verify task names against `mise.toml` before documenting them
- **File:** `.mise-tasks/upversion` (line 10)
- **Context tags:** docs, bash

**Found:**
```
bash scripts/upversion.sh
```

**Expected:**
```
mise run upversion
```

**Fix:** In `.mise-tasks/upversion`, update the DOCUMENTATION heredoc Usage line from `bash scripts/upversion.sh` to `mise run upversion`.

---

### W3: "setup script" reference for a script that no longer exists

- **Severity:** Warning
- **Rule:** Always verify task names against `mise.toml` before documenting them
- **File:** `docs/user-guide.md` (line 15), `README.md` (line 18)
- **Context tags:** docs

**Found:**
```
use the setup script to install dependencies, or alternately develop with Dev Containers
```

**Expected:**
```
run `mise install` to install dependencies, or alternately develop with Dev Containers
```

**Fix:** In both `docs/user-guide.md` (line 15) and `README.md` (line 18), replace "use the setup script to install dependencies" with "run `mise install` to install dependencies".

---

## Fix Instructions for Agent

1. [Violation] Move `set -euo pipefail` before `source "$(dirname "$0")/utils"` — `.mise-tasks/scaffold:24`
2. [Violation] Move `set -euo pipefail` before `source "$(dirname "$0")/utils"` — `.mise-tasks/upversion:45`
3. [Warning] Update DOCUMENTATION heredoc usage from `bash scripts/scaffold.sh` to `bash .mise-tasks/scaffold` — `.mise-tasks/scaffold:10`
4. [Warning] Update DOCUMENTATION heredoc usage from `bash scripts/upversion.sh` to `mise run upversion` — `.mise-tasks/upversion:10`
5. [Warning] Replace "use the setup script to install dependencies" with "run `mise install` to install dependencies" — `docs/user-guide.md:15` and `README.md:18`
