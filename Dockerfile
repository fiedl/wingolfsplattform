FROM ruby:2.7.1

ENV RAILS_ENV=development

# Debian Buster is EOL; its packages moved to archive.debian.org.
RUN sed -i -e 's|deb.debian.org/debian|archive.debian.org/debian|g' \
           -e 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' \
           -e '/buster-updates/d' /etc/apt/sources.list
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y aptitude ca-certificates

RUN aptitude install -y postgresql-client

# Install requirements for ruby gems.
RUN aptitude install -y libssl-dev g++ libxml2 libxslt-dev libreadline-dev libicu-dev imagemagick libmagick-dev
# The pg gem builds against libpq. Buster ships the v11 client tools,
# which work against the postgres 17 server for psql and pg_isready;
# pg_dump runs inside the postgres container instead (see script/dump).
RUN aptitude install -y libpq-dev
RUN aptitude install -y rsync
RUN aptitude install -y default-mysql-client
RUN aptitude install -y pwgen
RUN gem install bundler -v 2.1.4

# Install nodejs.
# The nodesource apt repository for node 12 is gone: install from the release tarball.
RUN aptitude install -y build-essential libssl-dev
RUN curl -fsSL https://nodejs.org/dist/v12.22.12/node-v12.22.12-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1
RUN node --version
RUN npm i -g yarn

# mimemagic >= 0.3.7 needs the freedesktop mime database:
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y shared-mime-info

# Patch minimagick policy to allow pdf conversion.
# https://stackoverflow.com/a/53180170/2066546
# https://stackoverflow.com/a/525612/2066546
# https://superuser.com/a/422467/273249
#
# This is ok for ghostscript >= 9.24, which we do have.
# https://www.kb.cert.org/vuls/id/332928/
#
RUN sed -i -e 's|<policy domain="coder" rights="none" pattern="PDF" />|<policy domain="coder" rights="read \| write" pattern="PDF" />|g' /etc/ImageMagick-6/policy.xml

RUN mkdir -p /app/wingolfsplattform
WORKDIR /app/wingolfsplattform
COPY Gemfile /app/wingolfsplattform/Gemfile
COPY Gemfile.lock /app/wingolfsplattform/Gemfile.lock
# The your_platform engine is loaded as a path-source gem and must be
# present for bundle install.
COPY your_platform /app/wingolfsplattform/your_platform
RUN bundle install
COPY . /app/wingolfsplattform

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["./start"]
