# This job deletes the caches of the given record in the background,
# e.g. after a structure change invalidates them wholesale.
# (Replaces the former `record.delay.delete_cache`: sidekiq 6 dropped
# the delay extension.)
#
class DeleteCacheJob < ApplicationJob
  queue_as :cache

  def perform(record:)
    record.delete_cache
  end
end
