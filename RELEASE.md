# Releasing

This repository releases **in lockstep**: one tag covers every action in it.

## Versioning scheme

- **`vX.Y.Z`** — an immutable, signed, annotated tag per release. Semantic versioning
  applies to the repository as a whole: a breaking change to *any* action's inputs or
  behaviour is a major bump.
- **`v1`** — a moving major tag, retargeted to the latest `v1.x.x` on every release.
  Consumers pinning `@v1` pick up fixes automatically.

Consumers choose their trade-off:

```yaml
- uses: owncloud/actions/<name>@v1                                        # convenient
- uses: owncloud/actions/<name>@0000000000000000000000000000000000000000  # immutable
```

**Accepted trade-off:** because releases are lockstep, a fix to one action bumps the
version for all of them. That is deliberate for a curated organisation toolkit — it
keeps one release cadence, one changelog and one governance surface. If an action ever
genuinely needs independent semver, promote it into its own `owncloud/action-<name>`
repository.

## Cutting a release

1. Make sure the default branch is green and every action has a passing self-test.
2. For any JavaScript action, rebuild and commit its `dist/` **before** tagging —
   GitHub runs the committed bundle, not the sources. (Composite actions have no
   build step; prefer them.)
3. Create the signed, annotated version tag on the release commit:

   ```bash
   git tag -s v1.2.0 -m "v1.2.0"
   git push origin v1.2.0
   ```

4. Retarget the moving major tag:

   ```bash
   git tag -f -s v1 -m "v1 -> v1.2.0"
   git push --force origin v1
   ```

5. Publish a GitHub Release for `v1.2.0` with notes describing, per action, what
   changed and whether consumers must act.

## Notes

- Tags must be **signed** — the organisation's branch policy requires signatures, and
  a release tag is part of the history consumers trust.
- The moving `v1` tag is the only force-push this repository performs. It is expected
  and only ever moves forward within the same major version.
- Publishing to the **GitHub Marketplace** is not possible from this repository: the
  root `action.yml` is a guard that errors, not a usable action, so a Marketplace
  listing can't point at it. A flagship action that should be publicly discoverable
  gets a thin `owncloud/action-<name>` repository whose root `action.yml` delegates
  here, so the logic stays single-sourced.
