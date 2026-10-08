# AGENTS.md -- ownCloud Actions

## Repository Overview

Monorepo of reusable **step-level** GitHub Actions for the ownCloud organisation,
covering both product lines: ownCloud Infinite Scale (`ocis-*` folders) and ownCloud
classic (`classic-*` folders). Each action is a top-level folder containing
`action.yml`, referenced by path as `owncloud/actions/<folder>@v1`. Public and
Apache-2.0 licensed, REUSE compliant.

- **Product family:** Infrastructure / Tooling
- **Primary language(s):** YAML (composite actions)
- **Companion repo:** `owncloud/reusable-workflows` — **job**-level `workflow_call`
  definitions. Step-level actions belong here; whole jobs belong there.

## Architecture & Key Paths

- `<name>/action.yml` -- one action per top-level folder. Naming is
  `<product>-<purpose>`: `ocis-*`, `classic-*`, or `shared-*` when it serves both.
- **The root `action.yml` is a guard, not a usable action.** This repository is a
  collection, not a single action, so `uses: owncloud/actions@v1` must fail loudly
  instead of silently resolving to nothing — the folder is always part of the
  reference. (Same model as `gradle/actions`.)
- `.github/workflows/` -- this repository's own CI: workflow/action linting and the
  self-tests that exercise each action.
- `RELEASE.md` -- the lockstep release process.

## Development Conventions

- **Prefer composite actions.** A JavaScript action requires a bundled `dist/`
  committed before tagging; composite actions avoid that machinery entirely. Only
  reach for JS when a composite action genuinely cannot do the job.
- **Every action must be referenced by a self-test workflow** as
  `uses: ./<folder>`. This is a hard requirement of the linting setup, not a
  nice-to-have: `actionlint` validates an `action.yml` only when a workflow
  references that local action, and it does **not** check a composite action's
  `steps:` at all. An unreferenced action is entirely unvalidated.
- **Lockstep versioning.** One signed `vX.Y.Z` tag for the whole repository plus a
  moving `v1`. A fix to one action bumps the version for all of them; that trade-off
  is accepted deliberately (see `RELEASE.md`).
- **No secrets in this repository.** It is public. Secrets are always passed in by
  the consuming workflow at runtime, and actions that need a token must degrade or
  skip gracefully when one is absent — fork pull requests do not receive secrets.

## Build & Test Commands

No build step for composite actions. Validate locally before pushing:

```bash
actionlint                 # workflows + the action.yml of every referenced local action
yamllint .                 # YAML hygiene
pipx run reuse lint        # licensing/copyright compliance (must pass)
```

## Important Constraints

- Changes here affect CI across the whole ownCloud organisation. A breaking change to
  an action's inputs is a major version bump, never a silent edit of `v1`.
- Licensed **Apache-2.0** from creation. Do not introduce **copyleft-licensed**
  dependencies (GPL, AGPL, LGPL, MPL) — raise an issue first.
- All contributions require a DCO sign-off.

## OSPO Policy Constraints

### GitHub Actions
- **Only** use actions owned by `owncloud`, created by GitHub (`actions/*`), verified
  on the GitHub Marketplace, or verified by the ownCloud Maintainers.
- Pin all actions to their full commit SHA (not tags): `uses: actions/checkout@<SHA> # vX.Y.Z`
- Never introduce actions from unverified third parties. A new third-party action also
  needs an entry in `actions-allowlist.yml` in `owncloud/admin`, pinned to a commit
  that has been public for at least seven days.

### Dependency Management
- Dependabot is configured for automated dependency updates (`github-actions` ecosystem).
- Review and merge Dependabot PRs as part of regular maintenance.
- Do not introduce new dependencies without discussion in an issue first.

### Git Workflow
- **Rebase policy**: Always rebase; never create merge commits. Use `git pull --rebase`
  and `git rebase` before pushing.
- **Signed commits**: All commits **must** be signed (`git commit -S -s`). The default
  branch requires signatures and linear history.
- **DCO sign-off**: Every commit needs a `Signed-off-by` line (`git commit -s`).
- **Conventional Commits & Squash Merge**: PR titles follow
  [Conventional Commits](https://www.conventionalcommits.org/) — the default branch is
  squash-merged, so the PR title becomes the commit message. A reusable workflow from
  `owncloud/reusable-workflows` enforces this.

## Governance

Repository settings, team access, branch protection, topics and `CODEOWNERS` are
managed centrally by [`owncloud/admin`](https://github.com/owncloud/admin) via
safe-settings. Do not edit `.github/CODEOWNERS` here — change
`codeowners/ownership.yml` in `owncloud/admin` instead. Owning team:
`@owncloud/infra-maintainers`.

## Context for AI Agents

Anything added here is consumed by CI across the entire organisation, so correctness
and backwards compatibility matter more than convenience. When adding an action:
create the folder, write `action.yml`, add its self-test workflow reference, document
the inputs, and add the row to the README table. The root `action.yml` is the guard
action — do not repurpose it into a real action.
