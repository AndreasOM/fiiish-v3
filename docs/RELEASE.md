# Release

How versions are numbered and how a build gets from a tag to the stores.

## Products

| Game            | Full      | Demo           | Notes                    |
|-----------------|-----------|----------------|--------------------------|
| Fiiish! Classic | `classic` | `demo-classic` | stepping stone, released |
| Fiiish! v3      | `v3`      | `demo`         | the long-term goal       |

Build types combine platform and product, e.g. `macos-classic`, `windows-demo-classic`, `ios`, `web-demo`.

## Versions

`v3.<minor>.<patch>`

| Rule                         | Example                  |
|------------------------------|--------------------------|
| Odd minor = development      | 3.15.x                   |
| Even minor = public          | 3.16.x (dev minor + 1)   |
| New year = new season        | 2026: 3.15, 2027: 3.17   |
| Big change bumps minor       | 3.15.22 → 3.17.23        |
| Dev patch = episode          | `[26E023]` → v3.15.23    |
| Public patch = last episode  | after E022 → v3.16.22    |

- **Odd minor:** stream builds only, never for normal users.
- **Even minor:** always the current dev minor + 1.
- **New year:** the first tag of a new year bumps the minor (+2), always.
- **Big change** (e.g. a rebalance): also bumps the minor mid-year. Small changes (new zones, fixes) don't. The patch keeps counting episodes.
- **Dev patch:** the episode of the year's season, as in the commit prefix.
- **Public patch:** the last episode included. If that number is already used, take the next one.
- **Off-stream:** public tags allowed, no dev tags. Untagged builds show the commit hash.
- **The past is frozen:** never retag, never reuse a version.

Commit prefixes: `[26E023]` for stream work (year + episode), `[OFFSTREAM]` otherwise.

Aim for a catch-up stream before a public release, so the public patch matches an episode. Off-stream releases between episodes should be rare.

### Edge cases

| Situation                                 | Do this                           |
|-------------------------------------------|-----------------------------------|
| 2nd public release before next episode    | next episode number: v3.16.23     |
| Public release before first episode       | patch 0: v3.18.0                  |
| Hotfix for older public line              | branch `release/3.16`, next patch |
| Dev + public tag on the same commit       | allowed, build uses public one    |
| Mistake or gap                            | gaps are fine, only go up         |

- A later stream E023 still becomes v3.15.23 after a public v3.16.23 (other minor, no clash).
- Dev + public tag on one commit (e.g. v3.15.22 + v3.16.22) is normal. The build must use the public one (see TODO).

### Floating tags

| Tag       | Marks                                     | Used for                         |
|-----------|-------------------------------------------|----------------------------------|
| `classic` | the classic build that should be uploaded | Classic and Classic demo uploads |
| `full`    | the v3 build that should be uploaded      | v3 and v3 demo uploads           |

Move the tag to the commit you want to ship, then upload:

```
git tag -f classic v3.16.22
git push -f origin classic
```

- Uploads check that the build's commit matches the floating tag (planned, see TODO).
- Floating tags never trigger a build and never count as a version.

## Release flow

| Step             | How                                  |
|------------------|--------------------------------------|
| 1. Tag           | push `v3.<minor>.<patch>`            |
| 2. Build         | automatic: "Classic - All - Build"   |
| 3. Floating tag  | move `classic` / `full`              |
| 4. Sign + upload | "Classic - All - Upload Latest"      |
| 5. Steam         | "Push latest to steam"               |
| 6. Go live       | by hand                              |
| 7. Announce      | by hand                              |

- **Build:** iOS, macOS, Linux, Windows (`*-classic`). Uploads to S3 and marks it as "latest" per build type. Web and demo builds: run "Build" by hand.
- **Floating tag:** points at the commit to ship. Uploads check it (planned).
- **Sign + upload:** signs macOS and iOS. Uploads iOS to App Store Connect, desktop to itch.io.
- **Steam:** checks that Linux, macOS and Windows have the same version. Build description = `vX.Y.Z`.
- **Go live:** Steamworks: set the build live on the branch. App Store Connect: TestFlight / submit for review.
- **Announce:** Steam community announcement titled `vX.Y.Z`.
- Only **even** versions go live for normal users. Dev builds go to test branches or TestFlight at most.
- Uploads always take the **latest build** of each type, which is the last build made, not necessarily the last tag. Check the version in the upload summary before going live.
- Untagged builds are `v0.0.0`. Uploading one is fine for quick test iterations (test branch or TestFlight), but only on purpose, never by accident.
- itch.io was for early access only and is unused now.
- The iOS build number is a timestamp (`2025.YYMMDD.HHMMSS`). The `2025.` prefix is known and stays for now; it must never go down.

## Public versions so far

Frozen, for reference:

| Date       | Steam         | Version             | Note                         |
|------------|---------------|---------------------|------------------------------|
| 2025-10-03 | Announcement  | v3.10.1             |                              |
| 2025-12-28 | Store release | most likely v3.13.x | odd, from before these rules |
| 2026-07-30 | Announcement  | v3.15.2             | odd, from before these rules |

Next public release: **v3.16.x**.
