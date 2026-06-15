## Rule: Context File

- When adding a new context file, use `AGENTS.md` name

## Rule: Secrets

- Never commit secrets, config files, or database files

## Rule: Git

- Never do a force push, always pull changes with `--rebase`
- Always fetch and rebase to the newest main before beginning any new work
- Always use conventional commits (e.g. `feat:`, `fix:`, `docs:`, `chore:`)
- Never add anything AI-agent related to commit messages or co-authorship
- Use infinitive form in commit messages and pull request descriptions (e.g. use `add` or `change` instead of `added` or `changed`)
- Before pushing bigger changes, run unit tests

## Rule: ASCII

- Don't use non-ASCII chars in source code (e.g. use `--` over em dash or `->` over arrow symbol)

## Rule: Python

- **Define below call site**: new functions/methods go BELOW the first place that calls them, never above
- Always write code with type annotations and never use `typing.Any` (use `object` & `isinstance` instead)
- Never add `type: ignore` unless it's an issue with 3rd party code; if type ignoring, always specify why with `type: ignore[reason1,reason2]`
- Watch deps: when removing an import of another package, check if it's still used, and remove it from deps if not
