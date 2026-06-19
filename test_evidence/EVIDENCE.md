# TraverseChildren Unknown-Flag Fix — Test Evidence

This file records the actual Go test commands that were run, the scope of
coverage, and the final results for the `TraverseChildren` unknown-flag fix.
Raw outputs are committed alongside this file for reviewer audit.

## Commands actually run

```
# 1. Build (verifies command.go / command_test.go compile cleanly)
go build ./...

# 2. Targeted regression suite (Traverse + FParseErrWhitelist)
go test -v -run "TestTraverse|TestFParseErrWhitelist" -count=1 ./...

# 3. Full test suite (regression guard for the whole package)
go test -v -count=1 ./...
```

Environment: Go 1.21.13, `GOPROXY=https://goproxy.cn,direct`, Linux container.
The single consolidated runner is [verify_traverse_fix.sh](file:///e:/solo-work-portable-full/eval/cobra/verify_traverse_fix.sh);
raw outputs are [target_tests_output.txt](file:///e:/solo-work-portable-full/eval/cobra/test_evidence/target_tests_output.txt)
and [full_suite_output.txt](file:///e:/solo-work-portable-full/eval/cobra/test_evidence/full_suite_output.txt).

## Result summary

| Run | Command | Exit | Result |
| --- | --- | --- | --- |
| Build | `go build ./...` | 0 | OK |
| Targeted suite | `go test -v -run "TestTraverse\|TestFParseErrWhitelist" -count=1 ./...` | 0 | PASS |
| Full suite | `go test -v -count=1 ./...` | 1 | 1 pre-existing unrelated failure |

## Targeted suite — covered tests (all PASS)

Every test below passed. See `target_tests_output.txt` for the verbatim trace.

### Core fix verification

| Test | Subtests | What it locks down |
| --- | --- | --- |
| `TestTraverseChildrenUnknownFlagStableError` | 6 | Unknown long flag `--unknown` at parent-front / mid / child-front / child-end, plus `--namespace=foo` and `--bar=true` equals-forms → stable `unknown flag: --unknown` |
| `TestTraverseChildrenUnknownFlagShortForm` | 2 | Same stability with short-flag neighbors |

### No-regression guards

| Test | Subtests | What it locks down |
| --- | --- | --- |
| `TestTraverseChildrenValidPathNoRegression` | 4 | Legal parent/child flag traversal (space + equals forms, bool + string) does not regress |
| `TestTraverseChildrenLastChildArgsNotPrematurelyParsed` | 1 | Last-level child args are not parsed during `Traverse` |
| `TestTraverseWithParentFlags` / `TestTraverseNoParentFlags` / `TestTraverseWithTwoSubcommands` | 3 | Existing Traverse behavior preserved |
| `TestTraverseWithBadParentFlags` | 1 | Bad parent flag still surfaces `unknown flag: --str` via execute |
| `TestTraverseWithBadChildFlag` | 1 | Child flag errors remain deferred to execute |

### FParseErrWhitelist.UnknownFlags semantics

| Test | Subtests | What it locks down |
| --- | --- | --- |
| `TestTraverseChildrenFParseErrWhitelist` | 3 | parent-front / parent-mid / child whitelisting stays intact under TraverseChildren |
| `TestFParseErrWhitelistBackwardCompatibility` | 1 | No whitelist → errors as before |
| `TestFParseErrWhitelistSameCommand` | 1 | Whitelist on same command |
| `TestFParseErrWhitelistParentCommand` | 1 | Parent whitelist does not leak to child |
| `TestFParseErrWhitelistChildCommand` | 1 | Child whitelist scoped to child |
| `TestFParseErrWhitelistSiblingCommand` | 1 | Sibling isolation |

### NoOptDefVal scenarios

| Test | Subtests | What it locks down |
| --- | --- | --- |
| `TestTraverseChildrenNoOptDefValFlags` | 2 | NoOptDefVal flag without value followed by subcommand, and with value followed by subcommand |

## Full suite note

The full suite (`full_suite_output.txt`) has exactly one failure:

- `TestFailGenFishCompletionFile` — pre-existing, unrelated to this change.

It is a nil-pointer panic in [fish_completions_test.go#L141](file:///e:/solo-work-portable-full/eval/cobra/fish_completions_test.go#L141):
the test asserts `GenFishCompletionFile` returns `os.ErrPermission`, which does
not occur when the test process runs as root (the container user), so `got` is
nil and `got.Error()` panics. This file is not touched by the fix. Additionally,
the version-flag regression guards pass in the full suite:

- `TestVersionFlagExecutedOnSubcommand` — PASS
- `TestShorthandVersionFlagExecutedOnSubcommand` — PASS

## Fix recap (for reviewer cross-reference)

Source: [command.go](file:///e:/solo-work-portable-full/eval/cobra/command.go)

1. Added a `boolFlag` interface + `isBoolFlagValue` helper so bool flags are
   never treated as needing a space-separated value
   ([command.go#L674-L681](file:///e:/solo-work-portable-full/eval/cobra/command.go#L674-L681)).
2. `flagTakesValue` / `shortFlagTakesValue` (for `stripFlags` /
   `argsMinusFirstX` in the Find path) conservatively treat unknown flags as
   value-taking, preserving prior `--version sub` behavior
   ([command.go#L683-L706](file:///e:/solo-work-portable-full/eval/cobra/command.go#L683-L706)).
3. `flagKnownToTakeValue` / `shortFlagKnownToTakeValue` (for `Traverse`) treat
   unknown flags as NOT value-taking, so an unknown flag cannot swallow the
   next subcommand token — this is the core fix
   ([command.go#L708-L731](file:///e:/solo-work-portable-full/eval/cobra/command.go#L708-L731)).
4. `Traverse` no longer calls `ParseFlags` on the `findNext == nil` branch,
   preserving the "last child args not parsed early" semantics
   ([command.go#L868-L876](file:///e:/solo-work-portable-full/eval/cobra/command.go#L868-L876)).

Tests: [command_test.go](file:///e:/solo-work-portable-full/eval/cobra/command_test.go)
