FROM ruby:2.7.1

ENV RAILS_ENV=development

RUN apt-get update -qq && apt-get install -y postgresql-client

# Install requirements for ruby gems.
RUN apt-get update && apt-get install -y aptitude
RUN aptitude install -y libssl-dev g++ libxml2 libxslt-dev libreadline-dev libicu-dev imagemagick libmagick-dev
RUN aptitude install -y rsync
RUN aptitude install -y default-mysql-client
RUN aptitude install -y pwgen

# Install nodejs.
RUN aptitude install -y build-essential libssl-dev
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash
RUN aptitude install -y nodejs
RUN node --version
RUN npm i -g yarn

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
RUN bundle install
COPY . /app/wingolfsplattform

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

#
#
#WORKDIR /app
#ADD . /app/
##RUN git clone https://github.com/fiedl/wingolfsplattform.git ./
#RUN gem install bundler
#RUN bundle install
##ADD config/database.yml config/database.yml
##ADD config/secrets.yml config/secrets.yml

CMD ["./start"]