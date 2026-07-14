# Spec baseline for the rails upgrade

Updated 2026-07-12 on the upgrade branch
(https://github.com/fiedl/wingolfsplattform/issues/126). The engine
specs run against the wingolfsplattform application itself; the
engine's demo app has been removed.

## Running the suite

From the repository root, dockerized (postgres 17, redis, selenium
chromium):

    # single spec files or folders during development
    bin/rspec your_platform/spec/models/user_spec.rb

    # a CI-style slice with automatic retry of failed examples
    bin/rspec_ci your_platform/spec/models

The full suite is sharded over many isolated docker compose projects
(COMPOSE_PROJECT_NAME), one slice per project; see the CI matrix in
.github/workflows/tests.yml for the canonical slices.

Do not run the development `rails`/`sidekiq` services while the suite
runs; a booting application alongside the suite has corrupted spec
results before.

## The gate

**The suite must be green: 0 failures — including the directories the
CI matrix does not run (mailers, requests, uploaders, core_ext,
helpers).** Known-broken areas are marked `pending` with a reference
to their GitHub issue, so the suite fails loudly both on regressions
and on silently-fixed pendings:

- https://github.com/fiedl/wingolfsplattform/issues/110 — 13 generic
  list-export specs (superseded by the app's own export classes)
- https://github.com/fiedl/wingolfsplattform/issues/111 — 13 Issue.scan
  specs (app scopes scanning to living wingolfiten; wingolf scoping
  itself still needs app-side specs)
- https://github.com/fiedl/wingolfsplattform/issues/112 — 1 term-report
  spec (CorporationScore expects the wingolf corporation substructure)
- https://github.com/fiedl/wingolfsplattform/issues/115 — assorted
  feature specs, pended individually

Resolved during the upgrade:

- https://github.com/fiedl/wingolfsplattform/issues/109 — the 7
  incoming-mail rejection specs were unpended by the mail 2.9 bump;
  the delivery-filter spec was deleted (the feature was removed in
  2020, commit 374a1d1a5).

The implicit-corporation-creation feature (`User#corporation_name=`)
and its 6 specs are commented out, not pending — see the
UserCorporations concern.

## History

- 2026-07-13, rails 8.1.3 / ruby 4.0.5 / postgres 17: full suite
  green across 24 shards, one gate per version hop (5.1, 5.2, 6.0,
  zeitwerk, 6.1, ruby 3.1, 7.0, 7.2 + haml 6, ruby 3.4, 8.1,
  ruby 4.0).
- 2026-07-12, rails 5.2.8.1 / ruby 2.7.1 / postgres 17: full suite
  green across 24 shards (~2000 examples).
- 2026-07-05, rails 5.0.7.2 / mysql 5.7, against the demo app (now
  removed): 1658 examples, 11 failures, 12 pending.
