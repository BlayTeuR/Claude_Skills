# Claude Skills

A [Claude Code](https://claude.com/claude-code) plugin marketplace: a small **core** plugin worth having in every session, plus a **bank of skills** you install one at a time, only in the projects that need them.

Everything installs with Claude Code's built-in `/plugin` commands. There is nothing to clone, copy or script.

## Contents

| Plugin | Category | What it gives you |
|---|---|---|
| [`core`](core/) | core | `grill-with-docs` (plus `grilling` and `domain-modeling`), a `relecteur` code-review sub-agent, and a hook that checks tests and review before Claude finishes a turn |
| [`find-skills`](bank/generic/find-skills/) | generic | Helps Claude discover and install skills from the open skills ecosystem (`npx skills find`) |

The bank is organised by category (`generic`, `frontend`, `crm`, `dataviz`, `backend`). Only `generic` has a skill so far; the others are placeholders that will fill up over time.

## Requirements

- Claude Code, in the terminal, the desktop app or an IDE.
- Git. On Windows, Claude Code runs hooks through Git Bash, so nothing else is needed.
- Node.js (`npx`) only if you use `find-skills`.

## Quick start

1. Add the marketplace:

   ```text
   /plugin marketplace add BlayTeuR/Claude_Skills
   ```

2. Install the core plugin for all your projects:

   ```text
   /plugin install core@claude-skills
   ```

   Choose the **user** scope when asked.

3. Start a **new session**: plugins are loaded when a session starts.

4. In any project, install a skill from the bank when you need it:

   ```text
   /plugin install find-skills@claude-skills
   ```

   Choose the **local** scope to keep it out of the project's repository (see [Scopes](#scopes)).

Run `/plugin` at any time to browse, enable, disable or uninstall plugins.

## What's in `core`

### `grill-with-docs`

A relentless interview that sharpens a plan or design and writes the glossary and architecture decision records (ADRs) as decisions crystallise. It is invoked manually, never automatically:

```text
/core:grill-with-docs
```

It relies on two helper skills shipped in the same plugin, `grilling` and `domain-modeling`. These come from [mattpocock/skills](https://github.com/mattpocock/skills).

### The `relecteur` sub-agent

A code reviewer ("relecteur" is French for "reviewer"). It reads your uncommitted changes and looks for bugs, regressions, security problems and missing tests. It reports blocking problems with file and line, or approves the review.

### The end-of-turn hook

When Claude is about to finish a turn and the repository has uncommitted changes, the hook checks two things:

1. **Tests pass.** The test command is detected automatically (`npm`/`pnpm`/`yarn test`, `pytest`, `cargo test`, `go test`, `mvn test`, `make test`). To override it, put the command on the first non-comment line of `.claude/test-command` in your project. A file containing only a comment turns the test check off.
2. **The changes have been reviewed.** The `relecteur` must have approved the *exact* current state of the code. Editing anything afterwards invalidates the approval. The approval is stored inside `.git/`, so it never shows up in `git status`.

If a check fails, Claude is told what is missing and keeps working. Limits to know about:

- The hook blocks **once** per turn to avoid infinite loops. If Claude stops a second time without fixing the problem, the turn ends anyway. It is a safety net, not a guarantee.
- It does nothing when there are no uncommitted changes or the folder is not a git repository.

## Scopes

When you install a plugin, Claude Code asks where to enable it:

| Scope | Stored in | Effect |
|---|---|---|
| `user` | `~/.claude/settings.json` | Active in all your projects |
| `project` | `.claude/settings.json` | Active for the project, **committed** so collaborators get it |
| `local` | `.claude/settings.local.json` | Active for you in this project, **not committed** |

A good default: `core` at user scope, bank skills at local scope.

## Updating

```text
/plugin marketplace update claude-skills
```

Plugins carry no version number, so they track the latest commit of the default branch.

## Optional: recommended settings

These are suggestions, not part of the plugins (a plugin cannot ship permission rules).

**Keep Claude away from your main branch.** Add this to `~/.claude/settings.json` so Claude cannot push to `main`/`master` or merge pull requests, and must ask before any other push:

```json
{
  "permissions": {
    "deny": [
      "Bash(git push * main)",
      "Bash(git push * master)",
      "Bash(git push *:main)",
      "Bash(git push *:master)",
      "Bash(gh pr merge *)"
    ],
    "ask": [
      "Bash(git push)",
      "Bash(git push *)"
    ]
  }
}
```

These rules are best effort: they match common command shapes, not every possible one. For a real guarantee, also enable branch protection on `main` in GitHub.

**Review workflow.** To make the `relecteur` part of every task, add a rule such as this to `~/.claude/CLAUDE.md`:

> Before finishing a task that changes code, invoke the `relecteur` sub-agent. Work on a branch and open a pull request instead of pushing to `main`.

## Troubleshooting

- **A newly installed skill or agent does not show up.** Start a new session.
- **Skill names have a prefix.** Plugin skills are namespaced as `/<plugin>:<skill>`, for example `/core:grill-with-docs`. Automatic triggering by description is not affected.
- **The hook blocks every turn on Windows in a project with a `Makefile`.** If the project has a `test:` target but `make` is not installed, the detected command fails. Create `.claude/test-command` with the real command, or with only a comment to disable the test check.
- **Tests run twice.** This happens when `core` is installed at user scope *and* the project also declares the same hook, as this repository does for its own development.

## Repository layout

```text
.claude-plugin/marketplace.json     the catalogue Claude Code reads
core/                               the core plugin
  .claude-plugin/plugin.json
  skills/                           grill-with-docs, grilling, domain-modeling
  agents/relecteur.md
  hooks/hooks.json, gates.sh
bank/<category>/<skill>/            one plugin per skill
  .claude-plugin/plugin.json
  skills/<skill>/SKILL.md
bank/_template/                     skeleton for a new skill
```

## Adding a skill to the bank

1. Copy `bank/_template/` to `bank/<category>/<your-skill>/` and rename `skills/nom-du-skill/` and the name inside `plugin.json` and `SKILL.md` (lowercase, hyphenated, unique across the bank).
2. Keep the `description` in `SKILL.md` on a single line: it is what triggers the skill.
3. Register the plugin in `.claude-plugin/marketplace.json`:

   ```json
   {
     "name": "your-skill",
     "source": "./bank/<category>/<your-skill>",
     "description": "One line.",
     "category": "<category>"
   }
   ```

4. If the skill comes from someone else, keep its license file in the plugin folder and add it to the credits below.
5. Open a pull request.

## Credits and licenses

Third-party skills are copied unchanged unless noted. Each license is kept next to the files it covers.

| Skills | Source | License |
|---|---|---|
| `grill-with-docs`, `grilling`, `domain-modeling` (in `core`) | [mattpocock/skills](https://github.com/mattpocock/skills), commit `5863806` | MIT, [`core/LICENSE-mattpocock-skills.txt`](core/LICENSE-mattpocock-skills.txt) |
| `find-skills` | [vercel-labs/skills](https://github.com/vercel-labs/skills), commit `50894c1` | MIT, [`bank/generic/find-skills/LICENSE-vercel-labs-skills.txt`](bank/generic/find-skills/LICENSE-vercel-labs-skills.txt) |

Changes made: in `grill-with-docs`, the helper skills are called `core:grilling` and `core:domain-modeling`, because plugin skills are namespaced. The upstream `agents/openai.yaml` files are not included.

**A note on `find-skills`:** it can suggest installing third-party skills with `npx skills add … -y`, which skips confirmation. Review the source and license of any skill before you install it.
