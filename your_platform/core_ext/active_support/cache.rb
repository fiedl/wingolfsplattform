# This extends the class of Rails.cache.
# This file is required by the cache_store_extension initializer.
#
module CacheStoreExtension
  attr_accessor :running_from_background_job

  def uncached
    @ignore_cache = true
    result = yield
    @ignore_cache = false
    return result
  end

  # All caches called within this block will be renewed, i.e. fresh
  # values calculated.
  #
  # To make sure each value is recalculated only
  # once and to manage dependent values, only cached values older than
  # the given `time` or, by default,
  # the time of calling `renew` are recalculated, which is the key
  # to our 2017 attempt of refactoring the caching system.
  #
  # Internal notes: https://trello.com/c/6dNTE3FL/1084-renew-cache
  #
  # Example:
  #
  #     Rails.cache.renew do
  #       user.complicated_cached_method
  #     end
  #
  # Another example:
  #
  #     class User < ApplicationRecord
  #       def renew_cache
  #         Rails.cache.renew do
  #           complicated_cached_method
  #         end
  #       end
  #     end
  #
  def renew(time = Time.zone.now)
    time = Time.at(time) unless time.kind_of? Time
    @use_renew_cache = self.use_renew_cache?
    store_renew_at_time_for_nested_calls(time)
    yield
    remove_renew_at_time_for_nested_calls
  end

  def renew_if(condition, time = Time.zone.now)
    result = nil
    if condition
      renew(time) { result = yield }
    else
      result = yield
    end
    return result
  end

  def store_renew_at_time_for_nested_calls(time)
    (@renew_at_times ||= []) << time
  end
  def remove_renew_at_time_for_nested_calls
    @renew_at_times.pop(1)
  end

  def renew_at
    @renew_at_times.try(:last)
  end

  def renew?
    @renew_at_times.try(:any?)
  end

  def fetch(key, options = {}, &block)
    # We need to have this in local memory. Otherwise, the value might change until
    # we compare the timestamps.
    r = renew_at

    renew_this_key = true if r && (e = entry(key)) && e.created_at && (e.created_at < r)
    renew_this_key = true if @ignore_cache
    renew_this_key = true if options[:force]

    # If the renew_cache mechanism is not to be used, which can be the case
    # in specs or as the mechanism is turned off globally, then just delete
    # the cache rather than renewing it.
    #
    # Then, the cache is fetched on demand. Note that this method does not
    # need to return the calculated result as this code is only executed
    # within `Rails.cache.renew` statements.
    #
    if (not @use_renew_cache) && renew?
      delete(key) if renew_this_key
      return
    end

    # Recalculate the value before calling the original `Rails.cache.fetch`
    # in order not to lock the redis server while calculating the result
    # of the expensive block.
    #
    # This fixes `Redis::TimeoutError` and the issues that arise from
    # blocking the redis server: https://github.com/fiedl/wingolfsplattform/issues/72
    #
    # TODO: Maybe this is not needed after upgrading to redis 3.3.3.
    # See https://github.com/redis/redis-rb/issues/650#issuecomment-278826491
    #
    if renew_this_key || read(key).nil?
      new_value = yield
    end

    super(key, {force: renew_this_key}.merge(options)) { new_value }
  end

  def delete_regex(regex)
    keys = raw_keys_by_regex(regex)
    redis.del(*keys) if keys.count > 0
  end

  # Logical keys (without the namespace prefix), matching the regex.
  # With redis_cache_store, the namespace is a key prefix applied by
  # ActiveSupport, so the raw redis keys carry it and the public cache
  # api expects keys without it.
  def find_keys_by_regex(regex)
    raw_keys_by_regex(regex).collect { |raw_key| raw_key.delete_prefix(namespace_prefix) }
  end

  def raw_keys_by_regex(regex)
    return [] unless respond_to? :redis
    prefix = namespace_prefix
    redis.keys.select { |raw_key| raw_key.delete_prefix(prefix) =~ regex }
  end
  private :raw_keys_by_regex

  def namespace_prefix
    namespace = merged_options(nil)[:namespace]
    namespace = namespace.call if namespace.respond_to? :call
    namespace.present? ? "#{namespace}:" : ""
  end
  private :namespace_prefix

  def find_entries_by_regex(regex)
    find_keys_by_regex(regex).collect { |key|
      entry = entry(key)
      {
        key: key,
        value: entry.value,
        created_at: entry.created_at,
        expires_at: Time.at(entry.expires_at)
      }
    }
  end

  # # This provides a solution to errors like
  # # "year too big to marshal: 16 UTC".
  # #
  # # Note that this error confusingly does not neccessarily have
  # # something to do with caching dates.
  # #
  # def rescue_from_too_big_to_marshal
  #   begin
  #     yield
  #   rescue ArgumentError, NameError => exc
  #     if exc.message.match(%r|year too big to marshal: (.+)|)
  #       yield.reload  # Reloading the ActiveRecord objects can help.
  #     else
  #       raise exc
  #     end
  #   end
  # end

  def rescue_from_other_errors(block_without_fetch, &block_with_fetch)
    begin
      yield
    rescue => e
      p "CACHE: RESCUE: #{e.message}"
      block_without_fetch.call  # Circumvent the caching at all.
    end
  end
  private :rescue_from_other_errors


  # In model specs, it's more efficient to fill the cache when it is needed rather than
  # renewing all caches.
  #
  # If not using renew_cache, the cache is just deleted, not renewed. Filling the cache
  # is on demand then.
  #
  # Note that this won't introduce any bulk deletions. Thus, in terms of testability,
  # this is the same behaviour as when using renew_cache.
  #
  def use_renew_cache?
    not ENV['NO_RENEW_CACHE']
  end

  def entry(name)
    options = merged_options(nil)
    key = normalize_key(name, options)
    # Keyword splat: since rails 6.1, read_entry takes **options.
    read_entry(key, **options)
  end

  # This method reveals when a cache entry has been created.
  #
  def created_at(name)
    Time.at(entry(name).created_at) if entry(name)
  end

end

ActiveSupport::Cache::Store.send(:prepend, CacheStoreExtension)

# The renew mechanism compares cache entries by write time. Rails 7.0
# stopped stamping entries (@created_at is initialized to 0.0 unless
# expiry bookkeeping needs it), so the stamp is restored here. The
# instance variable travels through Marshal, so persisted entries keep
# their original stamp across deploys.
module CacheEntryCreatedAtStamp
  def initialize(*args, **options)
    super
    @created_at = Time.now.to_f if !defined?(@created_at) || @created_at.nil? || @created_at == 0.0
  end
end
ActiveSupport::Cache::Entry.prepend CacheEntryCreatedAtStamp

class ActiveSupport::Cache::Entry
  def created_at
    Time.at(@created_at) if defined?(@created_at) && @created_at
  end
end