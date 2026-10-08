# ownCloud Actions

<!-- OSPO-managed README | Generated: 2026-09-07 | v2 -->

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE) [![REUSE status](https://api.reuse.software/badge/github.com/owncloud/actions)](https://api.reuse.software/info/github.com/owncloud/actions) [![ownCloud OSPO](https://img.shields.io/badge/OSPO-ownCloud-blue)](https://kiteworks.com/opensource)

Reusable **step-level GitHub Actions** for the ownCloud organisation, covering both
product lines: ownCloud Infinite Scale (`ocis-*`) and ownCloud classic (`classic-*`).
Each action lives in its own top-level folder and is referenced by path, so one
repository, one release cadence and one governance surface serve every ownCloud
repository's CI.

This repository is the companion of
[`owncloud/reusable-workflows`](https://github.com/owncloud/reusable-workflows). The
split follows GitHub's own boundary:

| Repository | Granularity | Referenced as |
|---|---|---|
| `owncloud/actions` | **step** level — composite / JS actions | `uses: owncloud/actions/<name>@v1` |
| `owncloud/reusable-workflows` | **job** level — `workflow_call` definitions | `uses: owncloud/reusable-workflows/.github/workflows/<name>.yml@<ref>` |

## Getting Started

Reference an action by its folder path from any workflow, in any repository:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - uses: owncloud/actions/<action-name>@v1
        with:
          # action-specific inputs
```

The repository root `action.yml` is a guard, not a usable action: this repository is
a collection, not a single action. `uses: owncloud/actions@v1` fails with an error
pointing you at the right folder — always include it.

## Available Actions

| Action | Reference | Purpose |
|---|---|---|
| `ocis-setup` | `uses: owncloud/actions/ocis-setup@v1` | Install an oCIS binary (release or pre-built) and start an instance with optional services — antivirus, email, full-text search, Keycloak IDP, WOPI collaboration apps. |
| `ocis-test` | `uses: owncloud/actions/ocis-test@v1` | Run oCIS Behat acceptance suites, litmus WebDAV tests, cs3api validator, or WOPI validator tests against a running instance. |

These actions were migrated from `mklos-kw/ocis-github-actions`
([owncloud/admin#218](https://github.com/owncloud/admin/issues/218)).

## Versioning

Releases are **lockstep**: one signed `vX.Y.Z` tag covers the whole repository, and
the moving major tag `v1` is retargeted to the latest `v1.x.x`.

- Pin `@v1` for convenience — you receive fixes and backwards-compatible additions.
- Pin `@<full-commit-sha>` for maximum supply-chain safety.

See [RELEASE.md](RELEASE.md) for the release process.

## Adding an Action

1. Create a top-level folder named `<product>-<purpose>` (`ocis-…`, `classic-…`, or
   `shared-…` when it applies to both product lines) containing `action.yml`.
2. Prefer a **composite** action. JavaScript actions require a committed `dist/`
   bundle, which is extra release machinery — see [RELEASE.md](RELEASE.md).
3. Add a self-test job in `.github/workflows/` that runs the action as
   `uses: ./<your-folder>`. This is not optional busywork: `actionlint` validates an
   `action.yml` **only** when a workflow references that local action, so an
   unreferenced action is never checked.
4. Add a row to the table above and document the inputs in the action's own folder.

## Part of ownCloud Infrastructure

These actions are consumed by repositories across the
[ownCloud GitHub organisation](https://github.com/owncloud). The repository is public
so that forks and external contributors' CI can resolve the same references the org
uses.

## Community & Support

**[Star](https://github.com/owncloud/actions)** this repo and **Watch** for release notifications!

- [ownCloud Website](https://owncloud.com)
- [Community Discussions](https://github.com/orgs/owncloud/discussions)
- [Matrix Chat](https://app.element.io/#/room/#owncloud:matrix.org)
- [Documentation](https://doc.owncloud.com)
- [Enterprise Support](https://owncloud.com/contact-us/)
- [OSPO Home](https://kiteworks.com/opensource)

## Contributing

We welcome contributions! Please read the [Contributing Guidelines](CONTRIBUTING.md)
and our [Code of Conduct](CODE_OF_CONDUCT.md) before getting started.

### Workflow

- **Rebase Early, Rebase Often!** We use a rebase workflow. Always rebase on the target branch before submitting a PR.
- **Dependabot**: Automated dependency updates are managed via Dependabot. Review and merge dependency PRs promptly.
- **Signed Commits**: All commits **must** be PGP/GPG/SSH signed. See [GitHub's signing guide](https://docs.github.com/en/authentication/managing-commit-signature-verification).
- **DCO Sign-off**: Every commit must carry a `Signed-off-by` line:
  ```
  git commit -s -S -m "your commit message"
  ```
- **Conventional Commits**: PR titles follow [Conventional Commits](https://www.conventionalcommits.org/); the default branch is squash-merged, so the PR title becomes the commit message.
- **GitHub Actions Policy**: Workflows may only use actions that are (a) owned by `owncloud`, (b) created by GitHub (`actions/*`), or (c) explicitly allowlisted by the org. Pin every third-party action to a full commit SHA.

## Security

**Do not open a public GitHub issue for security vulnerabilities.**

Report vulnerabilities at **<https://security.owncloud.com>** -- see [SECURITY.md](SECURITY.md).

Bug bounty: [YesWeHack ownCloud Program](https://yeswehack.com/programs/owncloud-bug-bounty-program)

## License

[Apache License 2.0](LICENSE). The repository is [REUSE](https://reuse.software)
compliant: licensing and copyright are declared in [REUSE.toml](REUSE.toml).

## About the ownCloud OSPO

The [Kiteworks Open Source Program Office](https://kiteworks.com/opensource), operating under
the [ownCloud](https://owncloud.com) brand, launched on May 5, 2026, to steward the open source
ecosystem around ownCloud's products. The OSPO ensures transparent governance, license compliance,
community health, and sustainable collaboration between the open source community and
[Kiteworks](https://www.kiteworks.com), which acquired ownCloud in 2023.

- **OSPO Home**: <https://kiteworks.com/opensource>
- **GitHub**: <https://github.com/owncloud>
- **ownCloud**: <https://owncloud.com>

For questions about the OSPO or licensing, contact ospo@kiteworks.com.

### License Migration to Apache 2.0

The OSPO is driving a strategic relicensing of ownCloud repositories toward the
[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0), following
the [Apache Software Foundation's third-party license policy](https://www.apache.org/legal/resolved.html).

**Current license: Apache-2.0.** This repository was created under the target license,
so no migration is pending. Do not introduce copyleft-licensed (GPL, AGPL, LGPL, MPL)
dependencies here.
