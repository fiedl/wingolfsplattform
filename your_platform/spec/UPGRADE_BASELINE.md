# Model-spec baseline for the rails upgrade

Recorded 2026-07-05 on the unification branch, directly after merging the
your_platform engine back into this repository
(https://github.com/fiedl/wingolfsplattform/issues/108).

Run from `your_platform/` inside the docker tests service
(ruby 2.7.1, rails 5.0.7.2, mysql 5.7, neo4j 3.5):

    bundle install
    bundle exec rake prepare_tests
    bundle exec rspec spec/models

## Baseline numbers

**1658 examples, 11 failures, 12 pending** (30:15 min)

The upgrade gate for every rails/ruby hop is **no NEW failures** — not a
green suite.

## The 11 known failures

7 historical failures in the incoming-mail area (pre-existing before the
unification, same set as on the last CI runs):

- spec/models/incoming_mail_spec.rb:168
- spec/models/incoming_mails/mail_without_authorization_spec.rb:30
- spec/models/incoming_mails/mail_without_authorization_spec.rb:42
- spec/models/incoming_mails/mail_without_authorization_spec.rb:51
- spec/models/incoming_mails/mail_without_authorization_spec.rb:63
- spec/models/incoming_mails/mail_without_authorization_spec.rb:64
- spec/models/received_post_mail_spec.rb:43

4 failures in spec/models/app_version_spec.rb (15, 17, 21, 27) caused by
the unification itself: AppVersion shells out to git
(`git describe --tags`, `git rev-parse`, `git config remote.origin.url`),
but the engine directory no longer has a `.git` of its own — it is a
subtree of the wingolfsplattform repository, and the test container only
mounts the engine directory. The github_commit_url spec additionally
expects the retired `fiedl/your_platform` remote. To be resolved when the
engine code is de-wingolfized/cleaned up after the upgrade.

## Caveat

Do not run the engine's `web` (demo app) service while the suite runs:
the two share the mysql/neo4j containers and the gems/tmp volumes, and a
booting demo app corrupts spec results (observed: 59 spurious failures).
