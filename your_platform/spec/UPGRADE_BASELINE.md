# Model-spec baseline for the rails upgrade

Updated 2026-07-05 on the unification branch
(https://github.com/fiedl/wingolfsplattform/issues/108). The engine
specs run against the wingolfsplattform application itself; the
engine's demo app has been removed.

## Running the suite

From the repository root, inside the docker tests service
(ruby 2.7.1, rails 5.0.7.2, mysql 5.7, neo4j 3.5):

    # one-time: create and load the parallel test databases
    docker compose run --rm tests /bin/bash -c \
      "bundle exec rake 'parallel:create[16]' 'parallel:prepare[16]'"

    # run the engine model specs, 16-fold parallel (~6 min)
    docker compose run --rm tests /bin/bash -c \
      "cd your_platform && bundle exec parallel_rspec -n 16 spec/models"

Do not run the development `rails`/`sidekiq` services while the suite
runs; a booting application alongside the suite has corrupted spec
results before.

## The gate

**The suite must be green: 0 failures.** Known-broken areas are marked
`pending` with a reference to their GitHub issue, so the suite fails
loudly both on regressions and on silently-fixed pendings:

- https://github.com/fiedl/wingolfsplattform/issues/109 — 7 incoming-mail
  rejection specs (nil-Sender crash in the patched mail 2.6.6; unpend at
  the mail-gem bump during the rails upgrade)
- https://github.com/fiedl/wingolfsplattform/issues/110 — 13 generic
  list-export specs (superseded by the app's own export classes)
- https://github.com/fiedl/wingolfsplattform/issues/111 — 13 Issue.scan
  specs (app scopes scanning to living wingolfiten; wingolf scoping
  itself still needs app-side specs)
- https://github.com/fiedl/wingolfsplattform/issues/112 — 1 term-report
  spec (CorporationScore expects the wingolf corporation substructure)

The implicit-corporation-creation feature (`User#corporation_name=`)
and its 6 specs are commented out, not pending — see the
UserCorporations concern.

## History

- 2026-07-05, against the demo app (now removed): 1658 examples,
  11 failures, 12 pending — the 7 incoming-mail failures above plus 4
  app_version specs that have since been fixed or explained by the
  unification.
