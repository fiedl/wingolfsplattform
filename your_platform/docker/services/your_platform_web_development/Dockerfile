FROM ruby:2.7.1

ENV RAILS_ENV=development

# Debian Buster is EOL; its packages moved to archive.debian.org.
RUN sed -i -e 's|deb.debian.org/debian|archive.debian.org/debian|g' \
           -e 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' \
           -e '/buster-updates/d' /etc/apt/sources.list
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y aptitude ca-certificates

# Install requirements for ruby gems.
RUN aptitude install -y libssl-dev g++ libxml2 libxslt-dev libreadline-dev libicu-dev imagemagick libmagick-dev
RUN gem install bundler -v 2.1.4

# Install nodejs.
# The nodesource apt repository for node 10 is gone: install from the release tarball.
RUN aptitude install -y build-essential libssl-dev
RUN curl -fsSL https://nodejs.org/dist/v10.24.1/node-v10.24.1-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1
RUN node --version
RUN npm i -g yarn

# Install helper packages.
RUN aptitude install -y pwgen

# mimemagic >= 0.3.7 needs the freedesktop mime database:
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y shared-mime-info

WORKDIR /app
CMD ["script/start"]
