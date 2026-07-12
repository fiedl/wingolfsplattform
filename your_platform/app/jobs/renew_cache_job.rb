# This job renews the cache of the given `record`.
# Only caches that are older than `options[:time]` are renewed.
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

  def perform(record_or_records, options)
    if record_or_records.respond_to? :each
      record_or_records.each { |record| perform_on_record(record, options) }
    else
      perform_on_record(record_or_records, options)
    end
  end

  def perform_on_record(record, options)
    Rails.cache.running_from_background_job = true
    Sidekiq.logger.info "Running RenewCacheJob for #{record.title} with #{options.to_s}.\n" unless Rails.env.test?
    renew_cache(record, options)
    Rails.cache.running_from_background_job = false
  end

  def renew_cache(record, options)
    with_timeout do
      if record
        if options[:method].present?
          Rails.cache.renew(options[:time]) { record.send(options[:method]) if record.respond_to?(options[:method]) }
        elsif options[:methods]
          Rails.cache.renew(options[:time]) do
            options[:methods].each do |method|
              record.send(method) if record.respond_to?(method)
            end
          end
        else
          record.renew_cache (options[:time])
        end
      end
    end
  end

  def self.perform_later(record_or_records, options = {})
    options[:time] ||= Time.zone.now
    options[:method] = options[:method].to_s
    super(record_or_records, options)
  end

end