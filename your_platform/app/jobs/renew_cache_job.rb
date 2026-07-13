# This job renews the cache of the given `records`.
# Only caches that are older than `time` are renewed.
#
class RenewCacheJob < ApplicationJob
  queue_as :cache

  def serialize
    # Keep sub-second precision: with whole seconds, cache entries
    # written in the same second as the change compare as "not older"
    # and wrongly survive the renewal.
    arguments.last[:time] = arguments.last[:time].to_f if arguments.last && arguments.last[:time]
    super
  end

  def perform(records:, time:, method: nil, methods: nil)
    Array(records).each { |record| perform_on_record(record, time:, method:, methods:) }
  end

  def perform_on_record(record, time:, method: nil, methods: nil)
    Rails.cache.running_from_background_job = true
    Sidekiq.logger.info "Running RenewCacheJob for #{record.title} with time: #{time}, method: #{method}, methods: #{methods}.\n" unless Rails.env.test?
    renew_cache(record, time:, method:, methods:)
    Rails.cache.running_from_background_job = false
  end

  def renew_cache(record, time:, method: nil, methods: nil)
    with_timeout do
      if record
        if method.present?
          Rails.cache.renew(time) { record.send(method) if record.respond_to?(method) }
        elsif methods
          Rails.cache.renew(time) do
            methods.each do |cached_method|
              record.send(cached_method) if record.respond_to?(cached_method)
            end
          end
        else
          record.renew_cache(time)
        end
      end
    end
  end

  def self.perform_later(records:, time: Time.zone.now, method: nil, methods: nil)
    super(records:, time:, method: method.to_s, methods:)
  end

end
