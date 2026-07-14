module ActionDispatch::Routing

  module RouteSetExtensions

    # This allows lambdas as subdomain parameter for `default_url_options`:
    #
    #    config.action_mailer.default_url_options = {
    #      host: 'my_platform.dev',
    #      port: 3000,
    #      protocol: 'http',
    #      subdomain: lambda { ... }
    #    }
    #
    # See also: http://stackoverflow.com/a/35209404/2066546
    #
    # The splat keeps the override signature-compatible across rails
    # versions (6.1 passes additional internal arguments).
    def url_for(options, *args)

      if options[:subdomain].respond_to? :call
        options[:subdomain] = options[:subdomain].call
      end

      # When `request.host` is not available, e.g. in mailers or sidekiq, then the
      # default host might be used.
      if super.include?(Rails.application.config.action_mailer.default_url_options[:host]) && Rails.application.config.action_mailer.default_url_options[:subdomain].respond_to?(:call)
        options[:subdomain] ||= Rails.application.config.action_mailer.default_url_options[:subdomain].call
      end

      super(options, *args)

    end
  end

  class RouteSet
    prepend RouteSetExtensions
  end

end