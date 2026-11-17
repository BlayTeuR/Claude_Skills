# Claude Skills

A [Claude Code](https://claude.com/claude-code) plugin marketplace: a **core** plugin worth having in every session (an engineering workflow from idea to reviewed code, plus a safety hook), and a **bank of skills** you install one at a time, only in the projects that need them.

Everything installs with Claude Code's built-in `/plugin` commands. There is nothing to clone, copy or script.

## Contents

| Plugin | Category | What it gives you |
|---|---|---|
| [`core`](core/) | core | The engineering workflow (`grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `code-review`, `retro`, `tdd` and their helpers), a `relecteur` code-review sub-agent, and a hook that checks tests and review before Claude finishes a turn |
| [`find-skills`](bank/generic/find-skills/) | generic | Helps Claude discover and install skills from the open skills ecosystem (`npx skills find`) |

The bank is organised by category (`generic`, `frontend`, `crm`, `dataviz`, `backend`). Only `generic` has a skill so far; the others are placeholders that will fill up over time.

## Requirements

- Claude Code, in the terminal, the desktop app or an IDE.
- Git. On Windows, Claude Code runs hooks through Git Bash, so nothing else is needed.
- Node.js (`npx`) only if you use `find-skills`.
- The GitHub CLI (`gh`), signed in, only if you choose GitHub as the issue tracker for the workflow below. The local-files tracker needs nothing.

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

4. In each project where you want the planning skills (`to-spec`, `to-tickets`, `code-review`), run the one-time setup:

   ```text
   /core:setup-matt-pocock-skills
   ```

5. Install a skill from the bank when you need it:

   ```text
   /plugin install find-skills@claude-skills
   ```

   Choose the **local** scope to keep it out of the project's repository (see [Scopes](#scopes)).

Run `/plugin` at any time to browse, enable, disable or uninstall plugins.

## The workflow in `core`

Plugin skills are namespaced, so you type `/core:<skill>`. The skills come from [Matt Pocock](https://www.aihero.dev/skills); this plugin packages them so they install in one step.

```text
Simple path   grill-with-docs ─▶ implement ─▶ (code-review)

Full path     grill-with-docs ─▶ to-spec ─▶ to-tickets ─▶ implement (one ticket at a time) ─▶ code-review ─▶ retro
```

### Which path should I take?

Use the **simple path** when the work fits in one sitting: a feature, a fix or a refactor you can describe and finish in a single session. Talk it through with `/core:grill-with-docs` if the idea is still fuzzy, then go straight to `/core:implement`. Skip `to-spec` and `to-tickets` entirely.

Use the **full path** when the work is too big for one session, when you want to split it across several sessions or agents, or when you want the plan recorded in an issue tracker:

| Signal | Path |
|---|---|
| You can describe the change in a few sentences and finish it today | Simple: `/core:implement` |
| The change is small and clear, no interview needed | Simple: `/core:implement` directly |
| The idea is vague and you want it challenged first | `/core:grill-with-docs`, then simple or full |
| It will take several sessions, or more than fits in one context window | Full: `/core:to-spec`, `/core:to-tickets`, then `/core:implement` per ticket |
| You want a written spec and tickets others (or later sessions) can pick up | Full |
| You are fixing a bug with a clear expected behaviour | Simple, with `/core:tdd` |

When in doubt, start simple. You can move to the full path later: `to-spec` turns the conversation you have already had into a spec, so nothing is lost.

### The skills

| Command | What it does | Starts |
|---|---|---|
| `/core:grill-with-docs` | Interviews you on a plan or design until it is sharp, and records the vocabulary in `GLOSSARY.md` and hard decisions in `docs/adr/` as they are settled | Manual |
| `/core:to-spec` | Turns the current conversation into a spec and publishes it to your issue tracker. It does not interview you again, and it agrees test boundaries (seams) with you | Manual |
| `/core:to-tickets` | Splits a plan or spec into small vertical-slice tickets, each sized for a fresh context window, with blocking relationships. You approve the list before it is published | Manual |
| `/core:implement` | Builds the work you describe or the ticket you reference, using `tdd`, runs type checks and tests, then calls `code-review` and commits to the **current branch** | Manual |
| `/core:code-review` | Reviews the diff since a point you give (commit, branch, tag) on two axes: the repository's coding standards and the original spec, using parallel sub-agents | Automatic or manual |
| `/core:retro` | Looks back at a coding session and suggests improvements to the agent's environment (instructions, tools, skills) | Manual |
| `/core:tdd` | Test-first loop with rules for good tests. Agrees the test boundaries with you before writing any test | Automatic or manual |
| `/core:setup-matt-pocock-skills` | One-time per project: choose the issue tracker and where the domain docs live (the triage-label step is skipped, because `triage` is not included) | Manual |

Helpers used by the skills above: `grilling`, `domain-modeling`, `codebase-design` and `writing-for-agents`.

*Automatic* means Claude may load the skill on its own when your request matches its description. *Manual* skills only run when you type the command.

### First time in a project

`/core:setup-matt-pocock-skills` explores the project, asks where issues live, and shows you a draft before writing anything. It then creates `docs/agents/issue-tracker.md` and `docs/agents/domain.md`, and adds an `## Agent skills` block to the project's `CLAUDE.md` (or `AGENTS.md` if that is the file the project already uses; if the project has neither, it asks which one to create). You have three tracker choices:

- **Local markdown files** (under `.scratch/`): works anywhere, needs no remote and no extra tools. A good default for solo projects.
- **GitHub Issues**: needs the GitHub CLI (`gh`), signed in. Version 2.94 or later gives native sub-issue and blocking links; older versions fall back to API calls.
- **GitLab Issues**: needs the GitLab CLI (`glab`), signed in.

On GitHub and GitLab, `to-spec` applies a `ready-for-agent` label that the setup does not create (that step belongs to `triage`, which is not included). If your tracker rejects the unknown label, create `ready-for-agent` once in the repository.

These files belong to the project, so decide whether to commit them or to keep this tooling local with `.gitignore`. `GLOSSARY.md` and `docs/adr/` (created later by `grill-with-docs`) are ordinary project documentation and usually worth committing.

### Good habits

- **Start from a feature branch.** `/core:implement` commits to the branch you are on. Create a branch first so you never commit straight onto `main`.
- **One ticket per session.** Tickets are sized for a fresh context window; run `/core:implement` on one at a time, in a new session.
- **Use `tdd` where it fits.** According to its upstream documentation, it suits behaviour with clear inputs and outputs (business rules, validation, request/response contracts) and does not suit configuration, wiring, glue code or plain CRUD. It also stops to agree test boundaries with you before writing any test, so running it on every edit would be impractical.
- **Critique before and after, not during.** `/core:grill-with-docs` challenges the plan before you code; `/core:code-review` challenges the result afterwards.

### Not included

These upstream skills are deliberately left out for now: `implement-spec` (a parallel version of `implement` using worktrees and one branch per ticket), `triage`, `wayfinder` and the experimental ones. Some setup files mention `/triage` or `/wayfinder`; those commands do not exist in this plugin.

## The safety hook and the reviewer

### The `relecteur` sub-agent

A code reviewer ("relecteur" is French for "reviewer"). It reads your uncommitted changes and looks for bugs, regressions, security problems and missing tests. It reports blocking problems with file and line, or approves the review.

### The end-of-turn hook

When Claude is about to finish a turn and the repository has uncommitted changes, the hook checks two things:

1. **Tests pass.** The test command is detected automatically (`npm`/`pnpm`/`yarn test`, `pytest`, `cargo test`, `go test`, `mvn test`, `make test`). To override it, put the command on the first non-comment line of `.claude/test-command` in your project. A file containing only a comment turns the test check off.
2. **The changes have been reviewed.** The `relecteur` must have approved the *exact* current state of the code. Editing anything afterwards invalidates the approval. The approval is stored inside `.git/`, so it never shows up in `git status`.

If a check fails, Claude is told what is missing and keeps working. Limits to know about:

- The hook blocks **once** per turn to avoid infinite loops. If Claude stops a second time without fixing the problem, the turn ends anyway. It is a safety net, not a guarantee.
- It does nothing when there are no uncommitted changes or the folder is not a git repository. Since `/core:implement` commits its work, the hook usually stays quiet after it; `code-review` is the review step in that flow.

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

**Working rules.** Add rules like these to `~/.claude/CLAUDE.md`:

> Work on a branch and open a pull request instead of pushing to `main`.
> Before finishing a task that changes code, invoke the `relecteur` sub-agent.
> For features and bug fixes with a defined behaviour, use the `tdd` skill. Skip it for configuration, glue code and documentation.

## Troubleshooting

- **A newly installed skill or agent does not show up.** Start a new session.
- **Skill names have a prefix.** Plugin skills are namespaced as `/<plugin>:<skill>`, for example `/core:implement`. Automatic triggering by description is not affected.
- **A skill tells you to run `/setup-matt-pocock-skills`.** Run `/core:setup-matt-pocock-skills`, once per project.
- **The hook blocks every turn on Windows in a project with a `Makefile`.** If the project has a `test:` target but `make` is not installed, the detected command fails. Create `.claude/test-command` with the real command, or with only a comment to disable the test check.
- **Tests run twice.** This happens when `core` is installed at user scope *and* the project also declares the same hook, as this repository does for its own development.

## Repository layout

```text
.claude-plugin/marketplace.json     the catalogue Claude Code reads
core/                               the core plugin
  .claude-plugin/plugin.json
  skills/                           the workflow skills and their helpers
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

Third-party skills are copied from the sources below. Each license is kept next to the files it covers.

| Skills | Source | License |
|---|---|---|
| `grill-with-docs`, `grilling`, `domain-modeling`, `to-spec`, `to-tickets`, `implement`, `code-review`, `retro`, `tdd`, `codebase-design`, `setup-matt-pocock-skills`, `writing-for-agents` (in `core`) | [mattpocock/skills](https://github.com/mattpocock/skills), commit `5863806` | MIT, [`core/LICENSE-mattpocock-skills.txt`](core/LICENSE-mattpocock-skills.txt) |
| `find-skills` | [vercel-labs/skills](https://github.com/vercel-labs/skills), commit `50894c1` | MIT, [`bank/generic/find-skills/LICENSE-vercel-labs-skills.txt`](bank/generic/find-skills/LICENSE-vercel-labs-skills.txt) |

Changes made to the Matt Pocock skills, all because plugin skills are namespaced: calls to other skills (`Skill tool with "tdd"`) and the `/setup-matt-pocock-skills`, `/domain-modeling` and `/grill-with-docs` hints now carry the `core:` prefix. The upstream `agents/openai.yaml` files are not included.

**A note on `find-skills`:** it can suggest installing third-party skills with `npx skills add … -y`, which skips confirmation. Review the source and license of any skill before you install it.
