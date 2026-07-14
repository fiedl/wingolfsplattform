require 'sidekiq'
require 'sidekiq/fetch'

module Sidekiq

  # This sidekiq fetcher fetches the left-most, i.e. newest job
  # first.
  #
  # ## Why?
  # The background jobs are mostly used to renew caches. We submit a
  # timestamp that allows to compare whether the cache has already
  # been renewed later than requested. If the jobs are processed in
  # the regular order, we cache the same value twice for subsequent
  # changes.
  #
  # This mirrors BasicFetch#retrieve_work of sidekiq 6.5 with blpop
  # instead of brpop; re-derive when bumping sidekiq.
  #
  class FetchNewestFirst < Sidekiq::BasicFetch

    def retrieve_work
      qs = queues_cmd
      if qs.size <= 1
        sleep(TIMEOUT)
        return nil
      end

      queue, job = redis { |conn| conn.blpop(*qs) }
      UnitOfWork.new(queue, job, config) if queue
    end

  end
end
