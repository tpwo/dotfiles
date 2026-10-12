This file presents rules which should be applied *always*. If a prompt is *directly against* one of the rules, mention the rule, and ask me for decision.

## General

- When adding a new project instructions file in the repo, use `.claude/CLAUDE.md` path
- Never commit secrets, config files, or database files
- Don't use non-ASCII chars in source code (e.g. use `--` over em dash or `->` over arrow symbol)

## Git

- Never add anything AI-agent related to commit messages or co-authorship
- Never do a force push, always pull changes with `--rebase`
- Always fetch and rebase to the newest main before beginning any new work
- Always use conventional commits (e.g. `feat:`, `fix:`, `docs:`, `chore:`)
- Use infinitive form in commit messages and pull request descriptions (e.g. use `add` or `change` instead of `added` or `changed`)

## Python

- **Define below call site**: new functions/methods go BELOW the first place that calls them, never above
- Never use single letter variable names, in exceptions do `except ... as exc/err`
- Inside a `try` block there should be only a single line, so we can better isolate exception handling. The rest of the code should be in `else` block
- Always write code with type annotations and never use `typing.Any` (use `object` & `isinstance` instead)
- Never add `type: ignore` unless it's an issue with 3rd party code; if type ignoring, always specify why with `type: ignore[reason1,reason2]`
- Watch deps: when removing an import of another package, check if it's still used, and remove it from deps (defined in setup.py, setup.cfg or pyproject.toml) if not needed
- When adding a new public module, class or function, remember to add a docstring for it. Also add docstrings for more complex private functions etc. For trivial cases docstring can be skipped.
- When monkeypatching (usually in unit tests) **always** use `with mock.patch.object` imported from unittest module. This is the safest way of monkeypatching.
- Never add imports inside functions or methods -- always at the top of the file. Exception: Airflow task functions, where local imports reduce scheduler parse time (tasks run in separate Python interpreters so the import cost is paid once per task execution, not per DAG parse).
