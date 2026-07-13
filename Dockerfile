# Multi-stage Dockerfile supporting both development and production builds.
#
# Development (the default in docker-compose.yml):
#     docker compose build web
# Production:
#     docker build --target production -t wingolfsplattform .

FROM ruby:3.1 AS base

RUN apt-get update && \
    apt-get install -y ca-certificates curl \
      default-mysql-client postgresql-client \
      imagemagick rsync pwgen \
      shared-mime-info

# Patch the imagemagick policy to allow pdf conversion.
# https://stackoverflow.com/a/53180170/2066546
# https://stackoverflow.com/a/525612/2066546
# https://superuser.com/a/422467/273249
#
# This is ok for ghostscript >= 9.24, which we do have.
# https://www.kb.cert.org/vuls/id/332928/
#
RUN sed -i -e 's|<policy domain="coder" rights="none" pattern="PDF" />|<policy domain="coder" rights="read \| write" pattern="PDF" />|g' /etc/ImageMagick-6/policy.xml

# Tool for waiting for the database, honoring WAIT_HOSTS (docker-compose-wait).
RUN curl -fsSL https://github.com/ufoscout/docker-compose-wait/releases/download/2.12.1/wait -o /wait && \
    chmod +x /wait

WORKDIR /rails
EXPOSE 3000


# Development stage: adds the toolchain for building gems and javascript.
# No COPY, no bundle install — the source is mounted by docker-compose.yml,
# and the gems live in the bundle-cache volume (installed on demand by
# bin/bundle_exec).
FROM base AS development

ENV RAILS_ENV=development

# libpq-dev: the pg gem builds against libpq.
RUN apt-get update && \
    apt-get install -y build-essential g++ \
      libssl-dev libxml2 libxslt-dev libreadline-dev libicu-dev libmagickwand-dev \
      libpq-dev

# The nodesource apt repository for node 12 is gone: install from the
# release tarball. Node 12 is the last line the legacy javascript
# toolchain (node-sass 4, webpack 2) builds against.
RUN curl -fsSL https://nodejs.org/dist/v12.22.12/node-v12.22.12-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1
RUN node --version
RUN npm i -g yarn

CMD ["/bin/bash"]


# Build stage for production: installs gems and javascript modules and
# precompiles the assets into the image.
FROM development AS build

ENV RAILS_ENV=production \
    DOCKER_BUILD=true \
    BUNDLE_WITHOUT="development:test"

COPY Gemfile Gemfile.lock ./
# The your_platform engine is loaded as a path-source gem and must be
# present for bundle install.
COPY your_platform ./your_platform
RUN bundle install --jobs 4

COPY . .

# yarn install + webpack build the vue packs into your_platform/vendor/packs,
# where the asset pipeline picks them up (see
# your_platform/lib/tasks/install_node_modules.rake — invoked directly here
# to avoid booting rails without a database).
RUN cd your_platform && yarn install --frozen-lockfile && \
    ./node_modules/.bin/webpack --config config/webpack.config.js

RUN SECRET_KEY_BASE=dummy_for_precompile bundle exec rails assets:precompile


# Final production image: runtime dependencies plus the built artifacts.
FROM base AS production

ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development:test"

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bin/server"]
