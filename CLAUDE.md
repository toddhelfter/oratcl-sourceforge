# Guidance for AI assistants working on Oratcl

## Copyright year

The copyright end-year in [license.terms](./license.terms) and [LICENSE](./LICENSE)
(`Copyright (c) 2000-YYYY Todd M. Helfter`) has historically been bumped at each
release, not left static — e.g. `2000-2004` for 4.3, `2000-2005` for 4.5,
`2000-2017` for 4.6, `2000-2026` for 5.0.

**When cutting a new release, bump the end-year in both `license.terms` and
`LICENSE` to match the release year**, following that historical pattern.
`COPYRIGHT` does not carry a year and does not need updating.

If this repo (`oratcl-sourceforge`) and `oratcl-source` are both still active,
apply the same bump in both places.

## Known accepted risk: SourceForge GitHub-integration webhook secret

`TODO.md`'s git history (commit `fa9d482` and others, Story 4) contains the real
SourceForge GitHub-integration webhook secret in plaintext. This was already public on
`origin/main` before being noticed; no self-service way to regenerate it was found on
SourceForge's integration admin page, and the blast radius is believed low (the webhook
likely only triggers SourceForge to pull release assets via GitHub's own API using the
already-configured repo association, not accept attacker-supplied payload content
directly). **Decision: accepted as low-severity, left as-is — do not rewrite git history
or treat this as a new finding requiring action**, unless new information changes that
risk assessment.
